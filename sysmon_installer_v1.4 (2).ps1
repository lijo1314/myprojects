## This Powershell script is used to install Sysmon
## The script is also going to make sure that the deployment of Sysmon is healthy, fix it if not or update it if necessary
## The script also adjusts the permissions for the Sysmon event log so they low privilaged Splunk user can read them
## It just works, don't worry about it. I hate Windows drivers.

$sysmon_binary_sysinternals = "https://live.sysinternals.com/Sysmon64.exe"
$sysmon_installer_path = "C:\Windows\Temp\sysmon.exe"
$sysmon_config_path = "C:\Windows\Temp\config.xml"
$sysmon_path = Get-ItemPropertyValue 'HKLM:\SYSTEM\CurrentControlSet\Services\Sysmon' -Name ImagePath -ErrorAction SilentlyContinue
if ($sysmon_path) {
    $sysmon_version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$sysmon_path").FileVersion
}
#$sysmon_temp_version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("$sysmon_installer_path").FileVersion
$sysmon_temp_version = "15.11"
$test = $false

$items = @(
    "C:\Windows\Sysmon64.exe",
    "C:\Windows\Sysmon.exe",
    "C:\Windows\SysmonDrv.sys",
    "HKLM:\SYSTEM\CurrentControlSet\Services\Sysmon64",
    "HKLM:\SYSTEM\CurrentControlSet\Services\Sysmon",
    "HKLM:\SYSTEM\CurrentControlSet\Services\SysmonDrv",
    "HKLM:\SYSTEM\ControlSet001\Services\Sysmon64",
    "HKLM:\SYSTEM\ControlSet001\Services\Sysmon",
    "HKLM:\SYSTEM\ControlSet001\Services\SysmonDrv",
    "HKLM:\SYSTEM\ControlSet002\Services\Sysmon64",
    "HKLM:\SYSTEM\ControlSet002\Services\Sysmon",
    "HKLM:\SYSTEM\ControlSet002\Services\SysmonDrv",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Sysmon/Operational",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Publishers\{5770385f-c22a-43e0-bf4c-06f5698ffbd9}",
    "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Microsoft-Windows-Sysmon-Operational"
    )

function fixPermissionsSysmonLog {
    Write-Host "[+] Attempting to check and adjust the permissions for the Sysmon event log"
    if ( Get-WinEvent -ListLog Microsoft-Windows-Sysmon/Operational) {
        Write-Host "[+] Event group exists, checking permissions"
        [xml]$sysmon_event_conf = wevtutil get-log Microsoft-Windows-Sysmon/Operational /f:xml
        $wevutil_code = $LastExitCode
        $current_channel = $sysmon_event_conf.channel.channelAccess 
        Write-Host "[+] Current permissions are: $current_channel"
        ## (A;;0x1;;;SU) is 0x1 Write for SU Service Users
        ## The low privilaged Splunk user runs under NT Service so we need that perm otherwise user cannot read the events
        if ($current_channel.Contains("(A;;0x1;;;SU)") -and $wevutil_code -eq 0) {
            Write-Host "[+] Sysmon event log has the (A;;0x1;;;SU) permission"
        }
        ## Checking if the current perms do not have the perm we need and if we the previous wevtutil command ran fine
        ## We don't want to compare and concat with nothing resulting in broken perms
        elseif (!($current_channel.Contains("(A;;0x1;;;SU)")) -and $wevutil_code -eq 0) {
            Write-Host "[-] Sysmon event log is missing the (A;;0x1;;;SU) permission, attempting to add"
            $correct_channel = "$current_channel" + "(A;;0x1;;;SU)"
            wevtutil set-log Microsoft-Windows-Sysmon/Operational /ca:$correct_channel
            [xml]$sysmon_event_conf_fixed = wevtutil get-log Microsoft-Windows-Sysmon/Operational /f:xml
            $fixed_channel = $sysmon_event_conf_fixed.channel.channelAccess
            Write-Host "[+] Added permissions, they are now: $fixed_channel"
            Write-Host "[+] Restarting Splunk Universal Forwarder so it can read the event log"
            & "C:\program files\splunkuniversalforwarder\bin\splunk.exe" restart
        }
    }
}
    
function install_sysmon {
	if ($test) {
		return
	}
	Write-Host "[+] Downloading Sysmon binary"
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Invoke-WebRequest -Uri $sysmon_binary_sysinternals -OutFile $sysmon_installer_path
	
    Write-Host "[+] Attempting to install Sysmon, attempting to uninstall as a precaution first"
    & "$sysmon_installer_path"  -u
    & "$sysmon_installer_path"  -accepteula -i "$sysmon_config_path"
    fixPermissionsSysmonLog
    Write-Host "[+] Veryfying deployment"
    test_deployement
}

## Sanity check after installation, if it fails then the script will try to fix it next time it runs
function test_deployement {
    if ((Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Sysmon" -ErrorAction SilentlyContinue) -and (Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SysmonDrv")) {
        Write-Host "[+] Registry seems good, we have both Sysmon and SysmonDriver"
    }
    else {
        Write-Host "[-] Something is off about Sysmon registry"
    }
    if ((Get-Service -Name sysmon -ErrorAction SilentlyContinue).Status -eq "Running") {
        Write-Host "[+] Sysmon process is running"
    }
    elseif ((Get-Service -Name sysmon -ErrorAction SilentlyContinue).Status -eq "Stopped")  {
        Write-Host "[-] Sysmon process is not running"
    }
    else {
        Write-Host "[-] Sysmon service doesnt seem to exist"
    }
}

## Checking if we have both the Sysmon and SysmonDriver
if ((Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Sysmon") -and (Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SysmonDrv")) {
    Write-Host "[+] Currently installed Sysmon v$sysmon_version"

    if ([System.Version]"$sysmon_version" -lt [System.Version]"$sysmon_temp_version") {
        Write-Host "[-] Currently installed version of Sysmon in $sysmon_path v$sysmon_version is outdated compared to the one in "$sysmon_installer_path" v$sysmon_temp_version"
        install_sysmon
    }
    else {
        Write-Host "[+] Currently installed Sysmon v$sysmon_version is recent"
    }
    ## Checking the config
    if (Test-Path -Path 'C:\Windows\config.xml') {
        if ( (Get-FileHash -Algorithm SHA256 'C:\Windows\config.xml').Hash -eq (Get-FileHash -Algorithm SHA256 "$sysmon_config_path").Hash)  {
            Write-Host "[+] Sysmon config matches"
        }
        else {
           Write-Host "[-] Sysmon config doesn't match, updating"
           & 'C:\Windows\sysmon.exe' -accepteula -c "$sysmon_config_path"
		   Copy-Item -Path "$sysmon_config_path" -Destination "C:\Windows\config.xml"
        }
    }
    else {
        Write-Host "[-] Sysmon config not found in expected location, force updating"
           & 'C:\Windows\sysmon.exe' -accepteula -c "$sysmon_config_path"
		   Copy-Item -Path "$sysmon_config_path" -Destination "C:\Windows\config.xml"
    }
    ## Checking if the Sysmon event log has correct permissions for Splunk low privilage user to read
    fixPermissionsSysmonLog
}
## Checking if we don't have both the Sysmon and SysmonDriver, something might be wrong
elseif (!((Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Sysmon" -ErrorAction SilentlyContinue) -eq (Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SysmonDrv" -ErrorAction SilentlyContinue)) ) {
    Write-Host "[-] Something weird with Sysmon deployment, attempting to reinstall"
    Stop-Service sysmon -Force
    Stop-Service sysmondrv -Force
    Write-Host "[+] Attempting to nuke all the Sysmon related files and registry keys"
    ## Nuking all Sysmon related files/registry keys 
    foreach ( $i in $items ) {
        $error.Clear();
        Remove-Item -Path $i -Force -Recurse -ErrorAction SilentlyContinue
        If($error) {
            $result = "[-] $error.Exception.Message"
        }
        Else {
            $result = "[+] Deleted $i"
        }
        Write-Host "$result".ToString()
    }
    install_sysmon
}
elseif ((Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Sysmon" -ErrorAction SilentlyContinue) -eq $true -and (Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SysmonDrv" -ErrorAction SilentlyContinue) -eq $true -and !(Get-Process -Name sysmon -ErrorAction SilentlyContinue)) {
    Write-Host "[-] Sysmon seems properly deployed but its not running, attempting to start service"
    Start-Service sysmon
}
else {
    Write "[-] Sysmon not installed, installing"
    install_sysmon
}