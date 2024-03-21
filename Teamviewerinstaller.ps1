$installerURL="https://download.teamviewer.com/download/version_15x/TeamViewer_MSI64.zip"

############### Do Not Edit Below This Line ###############

$installerTempLocation="C:\Windows\Temp\TeamViewer_MSI64.zip"
$installerLocation="C:\Windows\Temp\Host\Teamviewer_Host.msi"
if (Get-Service "TeamViewer" -ErrorAction SilentlyContinue) {
    Write-Host "Teamviewer already installed, nothing to do."
    exit 0
}
Write-Host "Teamviewer not installed."

Write-Host "Downloading Teamviewer installer now."
try {
    Invoke-WebRequest -Uri $installerURL -OutFile $installerTempLocation
}
catch {
    	Write-Error "Unable to download Teamviewer installer."
    exit 1
}
Write-Host "Finished downloading Teamviewer installer."

Write-Host "Installing 7zip4powershell module"
try {
    	Install-Module -Name 7Zip4Powershell -Force
}
catch {
	Write-Error "Unable to install 7zip4powershell."
    exit 1
}
Write-Host "Finished installing 7zip4powershell module."

Write-Host "Extracting Teamviewer MSI file"
try {
    	Expand-7Zip -ArchiveFileName $installerTempLocation -TargetPath 'C:\Windows\Temp\'
}
catch {
	Write-Error "Unable to extract Teamviewer installer."
    exit 1
}	
Write-Host "Installing Teamviewer now, this may take a few minutes."
try {
    #$args = @(,"/quiet","/norestart")
    $installerProcess = msiexec /i $installerLocation /quiet
}
catch {
    	Write-Error "Failed to run Teamviewer installer."
    exit 1
}
Write-Host "Teamviewer installer returned $($installerProcess.ExitCode)."

$files = @(
    'C:\Windows\Temp\TeamViewer_MSI64.zip',
    'C:\Windows\Temp\Host',
    'C:\Windows\Temp\Full',
    'C:\Windows\Temp\TeamViewer'
)
Remove-Item $files -Recurse -Force
exit
