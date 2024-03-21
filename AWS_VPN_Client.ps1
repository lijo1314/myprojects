$URL = "https://d20adtppz83p9s.cloudfront.net/WPF/latest/AWS_VPN_Client.msi"
$output = "C:\windows\temp\AWS_VPN_Client.msi"
(New-Object System.Net.WebClient).DownloadFile($url,$output)
pushd C:\windows\temp
.\AWS_VPN_Client.msi /quiet
