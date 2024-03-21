$CID=""
$installerURL="https://infosec-package-manager.s3.eu-west-1.amazonaws.com/WindowsSensor.LionLanner-6.37.15103.exe"

############### Do Not Edit Below This Line ###############

$installerTempLocation="C:\Windows\Temp\CSFalconAgentInstaller.exe"

if (Get-Service "CSFalconService" -ErrorAction SilentlyContinue) {
    Write-Host "Falcon Agent already installed, nothing to do."
    exit 0
}
Write-Host "Falcon Agent not installed."

Write-Host "Downloading Falcon Agent installer now."
try {
    Invoke-WebRequest -Uri $installerURL -OutFile $installerTempLocation
}
catch {
    Write-Error "Unable to download Falcon Agent installer."
    exit 1
}
Write-Host "Finished downloading Falcon Agent installer."

Write-Host "Installing Falcon Agent now, this may take a few minutes."
try {
    $args = @("/install","/quiet","/norestart","CID=$CID")
    $installerProcess = Start-Process -FilePath $installerTempLocation -Wait -PassThru -ArgumentList $args
}
catch {
    Write-Error "Failed to run Falcon Agent installer."
    exit 1
}
Write-Host "Falcon Agent installer returned $($installerProcess.ExitCode)."

exit $installerProcess.ExitCode
