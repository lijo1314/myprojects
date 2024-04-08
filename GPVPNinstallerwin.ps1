$installerURL="https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe"

############### Do Not Edit Below This Line ###############
$installerTempLocation="C:\Windows\Temp\GoogleDriveSetup.exe"

if (Get-Service “Google Drive” -ErrorAction SilentlyContinue) {
    Write-Host “Google Drive for Desktop already installed, nothing to do."
    exit 0
}
Write-Host “Google Drive for Desktop not installed."

Write-Host "Downloading Google Drive for Desktop installer now."
try {
    Invoke-WebRequest -Uri $installerURL -OutFile $installerTempLocation
}
catch {
    Write-Error "Unable to download Google Drive for Desktop installer."
    exit 1
}
Write-Host "Finished downloading Google Drive for Desktop installer."

Write-Host "Installing Google Drive for Desktop now, this may take a few minutes."
try {
   
    $installerProcess = Start-Process -FilePath $installerTempLocation -Verb runAs -ArgumentList --silent
}
catch {
    Write-Error "Failed to run Google Drive for Desktop installer."
    exit 1
}
Write-Host “Google Drive for Desktop installer returned $($installerProcess.ExitCode)."

exit $installerProcess.ExitCode
