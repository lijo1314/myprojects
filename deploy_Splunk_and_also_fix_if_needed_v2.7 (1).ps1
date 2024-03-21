#Requires -RunAsAdministrator
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$zzx_push_config_and_certs_deployment_server='[target-broker:deploymentServer]
targetUri = s-edge.security.letsgetchecked.com:8089'

$zzx_push_config_and_certs_outputs = '[tcpout]
defaultGroup = default-autolb-group

[tcpout:default-autolb-group]
server = s-hf.security.letsgetchecked.com:9997
clientCert = $SPLUNK_HOME/etc/apps/zzx_push_config_and_certs/files/AWSUFCombined.pem
sslPassword = 6foRGhvNRxWjKt2wycXmvz7fFT9qHnP9 
useSSL = true
useACK = false
sslVerifyServerCert = true
sslCommonNameToCheck = s-hf.security.letsgetchecked.com'

$zzx_push_config_and_certs_server='#config 2023-08
[general]
serverName = $HOSTNAME

[sslConfig]
sslPassword = 6foRGhvNRxWjKt2wycXmvz7fFT9qHnP9
sslRootCAPath = $SPLUNK_HOME/etc/apps/zzx_push_config_and_certs/files/AWS_CA_Cert.pem
serverCert = $SPLUNK_HOME/etc/apps/zzx_push_config_and_certs/files/AWSUFCombined.pem
sslVerifyServerCert = true
sslCommonNameToCheck = s-edge.security.letsgetchecked.com'

$zzx_push_config_and_certs_AWS_CA_Cert='-----BEGIN CERTIFICATE-----
MIID7jCCAtagAwIBAgIQcmBQi4MN7+pdJ9mFUuGc6TANBgkqhkiG9w0BAQsFADCB
kDELMAkGA1UEBhMCSUUxETAPBgNVBAgMCExlaW5zdGVyMQ8wDQYDVQQHDAZEdWJs
aW4xGTAXBgNVBAoMEExldHMgR2V0IENoZWNrZWQxHTAbBgNVBAsMFEluZm9ybWF0
aW9uIFNlY3VyaXR5MSMwIQYDVQQDDBpJbmZvU2VjU2lnbmluZyBDZXJ0aWZpY2F0
ZTAeFw0xOTA3MDUxMjM3MDJaFw0yOTA3MDUxMzM3MDJaMIGQMQswCQYDVQQGEwJJ
RTERMA8GA1UECAwITGVpbnN0ZXIxDzANBgNVBAcMBkR1YmxpbjEZMBcGA1UECgwQ
TGV0cyBHZXQgQ2hlY2tlZDEdMBsGA1UECwwUSW5mb3JtYXRpb24gU2VjdXJpdHkx
IzAhBgNVBAMMGkluZm9TZWNTaWduaW5nIENlcnRpZmljYXRlMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEAshN7D7U1FMU9mwiMs11XmOhSh4fNUTw74tR8
bEAd7IAAHzzuIVOHUlLtOPaWPfny+ABU+IpvzDvabilzL796oFDz63mJ9BYVmTzo
ccec78ewbyZNWt04YYJkvz5ySLxnljpyShpionvq4EkTszdZ6Re4/FUkwc5SWHjO
2ZhJB7IMbSoCR7NXRe73kyyrvICj+JTbhLozqHzBzxrxBzzLibC7ViciGdltxej1
GlX2h7jGPXHEuCSUF5yz//ey/cDGbIKQNs9PP2Su1TEhUafgzRqEXUbeop8tawsL
d26GXXhg+df0UHpAnOpvMOclfk0IpDdF2u9FLlG6/XTL+MuE1wIDAQABo0IwQDAP
BgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBSF/1tkLYEqdNfvavHRGpYD7mM47zAO
BgNVHQ8BAf8EBAMCAYYwDQYJKoZIhvcNAQELBQADggEBADmIF7kLOVA6kjo07VsU
UGggFKSsaa9tT7oPdrXBpUbp4dm7gcewC/E0qV7OBlz6O7eBisxsFIeC2s359x+k
ZA1VK8X0eK0jxYuDH1nArr0gdvDu8GJS1/42pNzTJh8QO7B1QchttIs2gUVD1St2
Ylwv+1a8K3XFVOCOOYpZ2/461jvhdl/JYqRtsByLt7DdqSEaLx5e2l4VEjfd8IXY
teXfi7WErceXGMzs4phwiR3GqpjzTLDlCOD55zTL0CuxrB0NdTTEyqglYFxLCPtH
22Ofcjrz1HLmKIhASiAgj36VvvlAs2lHVoepqQ8EUXkC5ZqUtrFQ2D706vKiUXZO
6vU=
-----END CERTIFICATE-----'

$zzx_push_config_and_certs_AWSUFCombined='-----BEGIN CERTIFICATE-----
MIIEcjCCA1qgAwIBAgIQa0BrQm34jgGc/tE3reoQejANBgkqhkiG9w0BAQsFADCB
kDELMAkGA1UEBhMCSUUxETAPBgNVBAgMCExlaW5zdGVyMQ8wDQYDVQQHDAZEdWJs
aW4xGTAXBgNVBAoMEExldHMgR2V0IENoZWNrZWQxHTAbBgNVBAsMFEluZm9ybWF0
aW9uIFNlY3VyaXR5MSMwIQYDVQQDDBpJbmZvU2VjU2lnbmluZyBDZXJ0aWZpY2F0
ZTAeFw0yMzA3MDYxNDA3NDVaFw0yNDA4MDYxNTA3NDVaMCsxKTAnBgNVBAMMIHMt
dWYuc2VjdXJpdHkubGV0c2dldGNoZWNrZWQuY29tMIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEAv7+vXs1nimhNd1Fifrdje7at+WuD49vbrqXIuU1COZYs
6N0/HcvXyb6Dn0K4+JyWuvJb6RDUpOfiBTpXyhnmdzJT8f66t0hn4/HzjoJJxjou
wMI3xtHpO8aZrB5j/HiSXvGX/XhwsCdAqU37ZDqJ7daeQG7zC5LA99Be8mOsp4Yo
hHHyaJ5BpI4ibVdIebLp01sOu7uewAQtiU7MYKJV1zMfeo43Rf5QPSBgEcp5pVT6
XdZNkx4tkNeHwdJ37oF6gJzQiOnbaZK88xEjYbOPUxqScvt/RBVvV9jz6sMzWdEd
aE/d+gG46wz1G4xLrFeClFtQqYvcp169Aw/S06zw1QIDAQABo4IBKjCCASYwKwYD
VR0RBCQwIoIgcy11Zi5zZWN1cml0eS5sZXRzZ2V0Y2hlY2tlZC5jb20wCQYDVR0T
BAIwADAfBgNVHSMEGDAWgBSF/1tkLYEqdNfvavHRGpYD7mM47zAdBgNVHQ4EFgQU
/fn3VZ5KJVmntAOBp901OsByFYMwDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQG
CCsGAQUFBwMBBggrBgEFBQcDAjB9BgNVHR8EdjB0MHKgcKBuhmxodHRwOi8vbGdj
LXNlY3VyaXR5LWNlcnRpZmljYXRlLWRhdGEuczMuZXUtd2VzdC0xLmFtYXpvbmF3
cy5jb20vY3JsL2U2ZjljYTE3LTYwNjctNDNlOC05NzllLWVkMDg0MmNkZWQ0Zi5j
cmwwDQYJKoZIhvcNAQELBQADggEBAF6vNup+C7UgRcW8Mut95ZIZ/rqadUncWRoq
ch8RUZJQESrJKxUes1iDIgHplIf6UN1hTP16UGjnfkqHoHU4XAdJvjA6TYz7M1bl
c0TawXU/ZQpiseJ8ZABRFRjMmQIVXZfWqGYfWzPrTdyCvuRLiHawwKYevjYdzLy1
Ru5QVIwMFDmLRxb68LhVVJH/nZ9hRvN1JEdKRnJwmpRAm+X1dPavdE5CRlUAra3P
FPXiE3u6x0VRckI/dnGIf09zJf0d6DZBMn7ocobIAzIXjeKyiFMPNu6uBAL4KTXs
Em1yL102s83dQO+TwRN/uEYk+lSYQYDdd1uxnakmX/tKLVlxzOM=
-----END CERTIFICATE-----
-----BEGIN ENCRYPTED PRIVATE KEY-----
MIIFKzBVBgkqhkiG9w0BBQ0wSDAnBgkqhkiG9w0BBQwwGgQU80wnG8lt7no8aRGt
VFiEjn7XINsCAggAMB0GCWCGSAFlAwQBKgQQdTHk60yXrWjZq60n6YC9TwSCBNDu
Rew5WwrheAs7jZZQ5/qZAHrPR8Uxh2pZeeFZ41HpjL98lGbXEiOV4VjtVo9zeGIV
Y7ONP6J9KNURCFw+6k+HJ/D8/X3fRESy1iUO8PAM1toyPN/+ecO31PRX775tN8bv
C90WIjyByV0NeKmgvodwNZVLmzgjgGShIY1U6k7hEadRUeL3vfm75gXuwvgJu5QX
cIjjMwXlInvnay6FpKgJ6uK0BYSk+/zdBtxfTJKijCz2zpGxnKrYQl+K9xA206rP
uTRHRhY4nAh5vvgZ0BBKsTlbra/8AC4yDQvgPGFiweFR3GX/JTq9nHNgZgD6uMkR
hwpr1+eVyDB4bq5KSGCD4GwDbBdXHO6x2InA7Eh0pJXpHJhkGUvz6y2QSiioHSWd
bN4fwj4ZRZI/S1gHHIO0tbdooROTXGsndA3xbzxPo/zl8wZDAoJ7S9VS/cmpJ8pm
KpT/+0VnGeynzHcIORBnQ8/YJLj9Yveif6fPIYoc9Mi55VDwTWV4ajG2Nzrg8dF7
BVjYiFQ1bD+Dg1L304++5a2CizgoYuzgtKXvDGSXrSfBR/8ncdoOUt3VgdllZ84C
uMuGdTf3Nx8QWOqTZz3j8JCO30fSmp8BK/glNAqU33nrC+M2ksSBxV+h2aBiR7bR
idQFLJ9S2MxSEV9osNuHueQkhkZVGMnTFN+952S1oTZV29CslUeYA0ryDOA8CqwQ
O4XfQM3R5hdTN8knBFGXbcdt73p/hbWteQKE5jkD+Cs78NzGeK/2ufWm7BV6c7mF
jyEpvGpxlMlOmwyB4HaKh9bbDcreiJduLT7mTTSzCOjrSzRrJ/Tei13wekQroYvF
YInSIMV0rAzN7Pfr+3d1zRkunsPjediYpLnDdk7UP4Wn0Of9pJK7BAr9KNxo58qq
NseYyWbkOZFDIvVsv58wx2Z6wRnqv+Z+fJL7awmz9iuXyuF4ApPVSz0t5/QtBchE
OjQC7mn22UDAxrzkZq/A6FgQAKysh0tAEZXDU8F4/1fCt5mFhP5NL2xBI5fWKzc/
erxXBbGxHMvMn+pqZ1+DVUYoysnRPp6OqdhwsgK7qnZVb9eOgvit0Quh8DeC3tP4
3aqkVzAwozX5lOh3MWWcGdGn6RK/jUacNpobQPSCPhcZey1s3hI3UbdSgF06yIhx
8MS+3C6bY5DsPoYWuOXx5ovST5c/C82EcEU0btiRuD8sKfb3ni4zOyBQEixr0dEh
znWZ22dDSbfFb47gVMcJhZNzgWHYjxzfHkvjFGqcKRnhIOnbVBg8qyZFFoc47b5X
rXgbec7JqtUP0YjpZBdUNYTCwdP/B3CmxD9Rh/dXCBXz3uyP9sDUEcQ2bEGef6Rt
xbXKQiddarTDIpm0H62Cj3MHKwRk79bw7/+gWqRXPBwWAl2WJ+RPGHW493OVt+GL
gHPFqG07lA9H5u2E9LI/rOyU6u6YBw2+kAU72mlG+ITDBjGAzRiNeU25G4uL7lZg
q/gasC5gYZ3IUWiQigcTBTlGnEmuHsYaM1VSUHW+gTnNlf5HxckJIbg4iTJTZDQV
7Uyquac5xXW3iV7uJKWnvOqKu8jt2B5W+LfHCcAtUXpVhqZhD8pijXu8j89qj7Ld
N91GzLm9QaNvku+8ta336Sfy6uANumWffRdFQLnn3g==
-----END ENCRYPTED PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIID7jCCAtagAwIBAgIQcmBQi4MN7+pdJ9mFUuGc6TANBgkqhkiG9w0BAQsFADCB
kDELMAkGA1UEBhMCSUUxETAPBgNVBAgMCExlaW5zdGVyMQ8wDQYDVQQHDAZEdWJs
aW4xGTAXBgNVBAoMEExldHMgR2V0IENoZWNrZWQxHTAbBgNVBAsMFEluZm9ybWF0
aW9uIFNlY3VyaXR5MSMwIQYDVQQDDBpJbmZvU2VjU2lnbmluZyBDZXJ0aWZpY2F0
ZTAeFw0xOTA3MDUxMjM3MDJaFw0yOTA3MDUxMzM3MDJaMIGQMQswCQYDVQQGEwJJ
RTERMA8GA1UECAwITGVpbnN0ZXIxDzANBgNVBAcMBkR1YmxpbjEZMBcGA1UECgwQ
TGV0cyBHZXQgQ2hlY2tlZDEdMBsGA1UECwwUSW5mb3JtYXRpb24gU2VjdXJpdHkx
IzAhBgNVBAMMGkluZm9TZWNTaWduaW5nIENlcnRpZmljYXRlMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEAshN7D7U1FMU9mwiMs11XmOhSh4fNUTw74tR8
bEAd7IAAHzzuIVOHUlLtOPaWPfny+ABU+IpvzDvabilzL796oFDz63mJ9BYVmTzo
ccec78ewbyZNWt04YYJkvz5ySLxnljpyShpionvq4EkTszdZ6Re4/FUkwc5SWHjO
2ZhJB7IMbSoCR7NXRe73kyyrvICj+JTbhLozqHzBzxrxBzzLibC7ViciGdltxej1
GlX2h7jGPXHEuCSUF5yz//ey/cDGbIKQNs9PP2Su1TEhUafgzRqEXUbeop8tawsL
d26GXXhg+df0UHpAnOpvMOclfk0IpDdF2u9FLlG6/XTL+MuE1wIDAQABo0IwQDAP
BgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBSF/1tkLYEqdNfvavHRGpYD7mM47zAO
BgNVHQ8BAf8EBAMCAYYwDQYJKoZIhvcNAQELBQADggEBADmIF7kLOVA6kjo07VsU
UGggFKSsaa9tT7oPdrXBpUbp4dm7gcewC/E0qV7OBlz6O7eBisxsFIeC2s359x+k
ZA1VK8X0eK0jxYuDH1nArr0gdvDu8GJS1/42pNzTJh8QO7B1QchttIs2gUVD1St2
Ylwv+1a8K3XFVOCOOYpZ2/461jvhdl/JYqRtsByLt7DdqSEaLx5e2l4VEjfd8IXY
teXfi7WErceXGMzs4phwiR3GqpjzTLDlCOD55zTL0CuxrB0NdTTEyqglYFxLCPtH
22Ofcjrz1HLmKIhASiAgj36VvvlAs2lHVoepqQ8EUXkC5ZqUtrFQ2D706vKiUXZO
6vU=
-----END CERTIFICATE-----'

$README_backup='
This directory contains local settings that override all other
settings, including the default settings, and specific configuration file
settings.

For details on configuration files, see $SPLUNK_HOME/etc/system/README/ directory
for specifications and examples.

'

$salty_ident='[deployment-client]
clientName = jumpcloud'

$splunk_msi_url = "https://download.splunk.com/products/universalforwarder/releases/9.2.0/windows/splunkforwarder-9.2.0-1fff88043d5f-x64-release.msi"
$splunk_msi_output_directory = "C:\Windows\Temp\splunk_universal_forwarder.msi"
$splunk_version_goal = "9.2.0"

$hostname_ec2 = $env:computername -like "EC2AMAZ-*"
$splunk_installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | Where { $_.DisplayName -eq "UniversalForwarder" }) -ne $null
$splunk_binary_exists = (Test-Path 'C:\Program Files\SplunkUniversalForwarder\bin\splunk.exe' -PathType leaf -ErrorAction SilentlyContinue) 

function string-checker {
    if (-not ([string]::IsNullOrEmpty($args[0]))) {        
        $True
    }
    else {
        $False
    }       
}

function Download-Splunk {
    Write-Host "[+] Downloading Splunk installer to Temp directory"
    (New-Object System.Net.WebClient).DownloadFile($splunk_msi_url,$splunk_msi_output_directory)
    Write-Host "[+] Downloaded Splunk installer to Temp directory"
}

function Check-Splunk-APPs {
    # Checking if default SSL password exists
    if ($default_ssl_password_exists) {
        Write-Host "[+] Default SSL password exists, deleting it"
        $deleting_default_ssl_password = @(Get-Content "C:\Program Files\SplunkUniversalForwarder\etc\system\local\server.conf") | Where-Object {$_ -notmatch 'sslPassword'} | Set-Content "C:\Program Files\SplunkUniversalForwarder\etc\system\local\server.conf"
    }
    # Checking system/local and juggling things if necessary
    if (Test-Path -Path 'C:\Program Files\SplunkUniversalForwarder\etc\system\local') {
        Write-Host "[+] system\local exists for this Splunk UF, proceeding"
    
        if (Test-Path -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzz_system_local_copy\local') {
            Write-Host "[+] APP with system\local already exists, not creating"
        }
        else {
            Write-Host "[+] APP with system/local doesn't exists, creating"
            New-Item -ItemType "directory" -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzz_system_local_copy\local'
        }
    
        if ((Get-ChildItem -Path 'C:\Program Files\SplunkUniversalForwarder\etc\system\local' -Name).Count -gt 1 -and (Test-Path -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzz_system_local_copy\local') -and ((Get-ChildItem -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzz_system_local_copy\local' -Name).Count -eq 0) )  {
            Write-Host "[+] Files exists in system/local, moving everything but README to APP"
            Move-Item -Path 'C:\Program Files\SplunkUniversalForwarder\etc\system\local\*' -Destination 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzz_system_local_copy\local' -Exclude "README" -erroraction 'silentlycontinue'
        }
    }
    elseif ((Test-Path -Path 'C:\Program Files\SplunkUniversalForwarder\etc\system\local' -ErrorAction SilentlyContinue) -eq $False) {
        Write-Host "[+] system\local doesn't exists for this Splunk UF, assuming previous version of this script executed successfully. It'll cause issues in future. Attempting to fix."
        New-Item -ItemType "directory" -Path 'C:\Program Files\SplunkUniversalForwarder\etc\system\local'
        Move-Item -Destination 'C:\Program Files\SplunkUniversalForwarder\etc\system\local' -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzz_system_local_copy\local\*' -Include "README" -erroraction 'silentlycontinue'
    }
    # Checking the cert APP
    if ($zzx_push_config_and_certs_exists) {
        Write-Host "[+] zzx_push_config_and_certs directory exists, assuming that this Splunk UF has the certs"
    }
    else {
        Write-Host "[+] zzx_push_config_and_certs directory doesn't exist, assuming that this Splunk UF doesn't have the certs"
        Write-Host "[+] Creating the zzx_push_config_and_certs directory"
        New-Item -ItemType "directory" -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\files'
        New-Item -ItemType "directory" -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\local'

        Write-Host "[+] Creating the config files and certs"
        New-Item -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\local' -Name outputs.conf -ItemType "file" -Value $zzx_push_config_and_certs_outputs
        New-Item -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\local' -Name server.conf -ItemType "file" -Value $zzx_push_config_and_certs_server
        New-Item -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\files' -Name AWS_CA_Cert.pem -ItemType "file" -Value $zzx_push_config_and_certs_AWS_CA_Cert
        New-Item -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\files' -Name AWSUFCombined.pem -ItemType "file" -Value $zzx_push_config_and_certs_AWSUFCombined
        New-Item -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\local' -Name deploymentclient.conf -ItemType "file" -Value $zzx_push_config_and_certs_deployment_server
    }
        if ($lgc_salty_exists) {
        Write-Host "[+] Directory exists, assuming that this Splunk UF has the ident"
    }
    else {
        Write-Host "[+] Directory doesn't exist, assuming that this Splunk UF doesn't have the ident"
        Write-Host "[+] Creating the directory"
        New-Item -ItemType "directory" -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\lgc_salty\local'

        Write-Host "[+] Creating the config file"
        New-Item -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\lgc_salty\local' -Name deploymentclient.conf -ItemType "file" -Value $salty_ident
    }
    if (($(Get-Content "C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\files\AWSUFCombined.pem" -Raw) -ne $zzx_push_config_and_certs_AWSUFCombined) -or
    !($(Get-Content "C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\local\server.conf" -Raw) -match "#config 2023-08") )  {
     
        Write-Host "[+] config files in zzx_push_config_and_certs directory are different from the script, overwriting"
        Out-File "C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\local\server.conf" -NoNewline -Encoding ascii -InputObject $zzx_push_config_and_certs_server
        Out-File "C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\local\outputs.conf" -NoNewline -Encoding ascii -InputObject $zzx_push_config_and_certs_outputs
        Out-File "C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\files\AWSUFCombined.pem" -NoNewline -Encoding ascii -InputObject $zzx_push_config_and_certs_AWSUFCombined
        & "C:\program files\splunkuniversalforwarder\bin\splunk.exe" restart 
    }
}

if($splunk_installed) {
    $splunk_integrity_check = string-checker(((& "C:\program files\splunkuniversalforwarder\bin\splunk.exe" validate files) -match 'All installed files intact'))

    $splunk_version = (& "C:\program files\splunkuniversalforwarder\bin\splunk.exe" version) -match 'Forwarder\s(?<splunk_ver>[\d\.]+)'
    $splunk_version = $Matches.splunk_ver
    $splunk_version_comparison = $splunk_version -match $splunk_version_goal
    $splunk_running = [bool](Get-Process -Name "splunkd" -ErrorAction SilentlyContinue)

    $zzx_push_config_and_certs_exists = (Test-Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs' -ErrorAction SilentlyContinue)
    $default_ssl_password_exists = [bool]((Get-Content "C:\Program Files\SplunkUniversalForwarder\etc\system\local\server.conf" -ErrorAction SilentlyContinue) | Select-String -pattern "sslPassword") 
    $lgc_salty_exists = (Test-Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\lgc_salty' -ErrorAction SilentlyContinue)
}

Write-Host "[+] Is Splunk installed: "$splunk_installed
Write-Host "[+] Does splunk.exe exist: "$splunk_binary_exists
Write-Host "[+] Is Splunk running: "$splunk_running
Write-Host "[+] Does the Splunk file integrity check pass: "$splunk_integrity_check
Write-Host "[+] What version of Splunk is installed: "$splunk_version
Write-Host "[+] Is the version of Splunk current: "$splunk_version_comparison
Write-Host "[+] Is the default SSL cert password present: "$default_ssl_password_exists
Write-Host "[+] Does the APP with self-signed certs exist: "$zzx_push_config_and_certs_exists
Write-Host "[+] Does the APP with ident exist: "$lgc_salty_exists
Write-Host "[+] Is this an EC2 instance: "$hostname_ec2
    
if(($hostname_ec2 -eq $False) -and (($splunk_installed -eq $False) -or ($splunk_version_comparison -eq $False -and $splunk_binary_exists -eq $True)) -and (($splunk_integrity_check -eq $True) -or ($splunk_integrity_check -eq $null) -or ($splunk_integrity_check -eq $False -and $splunk_version_comparison -eq $False) )) {
    if ($splunk_installed -eq $False) {
        Write-Host "[+] Splunk doesn't seem to be installed, I'll try to install it now"
    }
    elseif ($splunk_version_comparison -eq $False) {
        if ($splunk_integrity_check -eq $False){
            Write-Host "[+] Splunk file integrity check failed and Splunk is outdated, we can easily fix both with an upgrade"
        }
        else {
            Write-Host "[+] Splunk doesn't seem to be on the recent version, I'll try to upgrade it now"
        }
        if ($splunk_running){
            Write-Host "[+] Stopping Splunk"
            & "C:\program files\splunkuniversalforwarder\bin\splunk.exe" stop
        }
    }
    
    Download-Splunk
    Write-Host "[+] Installing Splunk but not starting"
    Start-Process C:\Windows\System32\msiexec.exe -ArgumentList "/i C:\Windows\Temp\splunk_universal_forwarder.msi GENRANDOMPASSWORD=1 LAUNCHSPLUNK=0 SERVICESTARTTYPE=auto AGREETOLICENSE=yes /quiet" -wait
    Write-Host "[+] Splunk installed"
    Check-Splunk-APPs
    Write-Host "[+] Starting Splunk"
    & "C:\program files\splunkuniversalforwarder\bin\splunk.exe" start
}
elseif ($hostname_ec2 -eq $False -and $splunk_installed -eq $True -and ($zzx_push_config_and_certs_exists -eq $False -or $default_ssl_password_exists )) {
    Write-Host "[+] For some reason configuration wasn't applied properly, attempting to fix it"
    Write-Host "[+] Stopping Splunk"
    & "C:\program files\splunkuniversalforwarder\bin\splunk.exe" stop
    Check-Splunk-APPs
    Write-Host "[+] Starting Splunk"
    & "C:\program files\splunkuniversalforwarder\bin\splunk.exe" start
}
elseif( ($hostname_ec2 -eq $False) -and (($splunk_integrity_check -eq $False) -or ($splunk_binary_exists -eq $False -and $splunk_installed -eq $True)) ) {
    if ($splunk_integrity_check -eq $False) {    
        Write-Host "[+] Splunk integrity check failed, checking if we can fix it before reinstalling"
        $splunk_integrity_check = (& "C:\program files\splunkuniversalforwarder\bin\splunk.exe" validate files)
        if ( (($splunk_integrity_check) | Measure-Object -Line).Lines -eq 2 -and (string-checker(($splunk_integrity_check -match 'system\/local\/README.*cannot find the path'))) ) {
            Write-Host "[+] We're missing a single file, trying to get it back"
            $README_exists = (Test-Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzz_system_local_copy\local\README' -PathType leaf -ErrorAction SilentlyContinue)
            if ($README_exists) {
                Write-Host "[+] Found the file, checking if we can restore it"
                if ((Test-Path -Path 'C:\Program Files\SplunkUniversalForwarder\etc\system\local') -eq $False) {
                    Write-Host "[+] system\local doesn't exists for this Splunk UF, assuming previous version of this script executed successfully. It'll cause issues in future. Attempting to fix."
                    New-Item -ItemType "directory" -Path 'C:\Program Files\SplunkUniversalForwarder\etc\system\local'
                }
                Move-Item -Destination 'C:\Program Files\SplunkUniversalForwarder\etc\system\local' -Path 'C:\Program Files\SplunkUniversalForwarder\etc\apps\zzz_system_local_copy\local\*' -Include "README" -erroraction 'silentlycontinue'
                $splunk_integrity_check_after_fix = string-checker(((& "C:\program files\splunkuniversalforwarder\bin\splunk.exe" validate files) -match 'All installed files intact'))
                Write-Host "[+] Does the Splunk file integrity check pass now: "$splunk_integrity_check_after_fix
            }
            else {
                if ((Test-Path -Path 'C:\Program Files\SplunkUniversalForwarder\etc\system\local') -eq $False) {
                    Write-Host "[+] system\local doesn't exists for this Splunk UF, assuming previous version of this script executed successfully. It'll cause issues in future. Attempting to fix."
                    New-Item -ItemType "directory" -Path 'C:\Program Files\SplunkUniversalForwarder\etc\system\local'
                }
                New-Item -Path 'C:\Program Files\SplunkUniversalForwarder\etc\system\local' -Name 'README' -ItemType "file" -Value $README_backup
                $splunk_integrity_check_after_fix = string-checker(((& "C:\program files\splunkuniversalforwarder\bin\splunk.exe" validate files) -match 'All installed files intact'))
                Write-Host "[+] Does the Splunk file integrity check pass now: "$splunk_integrity_check_after_fix               
            }
        }
    }
    else {
        if ($splunk_binary_exists -eq $False -and $splunk_installed -eq $True) {
            Write-Host "[+] Splunk binary doesn't exist but Windows is telling us that Splunk is installed"
            Uninstall-Package -Name "UniversalForwarder"
            Remove-Item "C:\program files\splunkuniversalforwarder" -Recurse
        }
        Write-Host "[+] We need to reinstall Splunk"
        if ($splunk_running){
            Write-Host "[+] Stopping Splunk"
            & "C:\program files\splunkuniversalforwarder\bin\splunk.exe" stop
            Write-Host "[+] Uninstalling Splunk"
            Uninstall-Package -Name "UniversalForwarder"
        }
        Download-Splunk
        Write-Host "[+] Installing Splunk but not starting"
        Start-Process C:\Windows\System32\msiexec.exe -ArgumentList "/i C:\Windows\Temp\splunk_universal_forwarder.msi GENRANDOMPASSWORD=1 LAUNCHSPLUNK=0 SERVICESTARTTYPE=auto AGREETOLICENSE=yes /quiet" -wait
        Write-Host "[+] Splunk installed"
        Check-Splunk-APPs
        Write-Host "[+] Starting Splunk"
        & "C:\program files\splunkuniversalforwarder\bin\splunk.exe" start
    }
}
elseif (($(Get-Content "C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\files\AWSUFCombined.pem" -Raw) -ne $zzx_push_config_and_certs_AWSUFCombined) -or
!($(Get-Content "C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\local\server.conf" -Raw) -match "#config 2023-08") )  {
 
    Write-Host "[+] config files are different from the script, overwriting"
    Out-File "C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\local\server.conf" -NoNewline -Encoding ascii -InputObject $zzx_push_config_and_certs_server
    Out-File "C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\local\outputs.conf" -NoNewline -Encoding ascii -InputObject $zzx_push_config_and_certs_outputs
    Out-File "C:\Program Files\SplunkUniversalForwarder\etc\apps\zzx_push_config_and_certs\files\AWSUFCombined.pem" -NoNewline -Encoding ascii -InputObject $zzx_push_config_and_certs_AWSUFCombined
    & "C:\program files\splunkuniversalforwarder\bin\splunk.exe" restart
    
}
elseif ( ($hostname_ec2 -eq $False) -and $splunk_installed -eq $True -and $splunk_binary_exists -eq $True -and $splunk_running -eq $False  ) {
    if ($splunk_running -eq $False) {
        Write-Host "[+] Splunk is not running, starting it"
        & "C:\program files\splunkuniversalforwarder\bin\splunk.exe" start
    }
    if ((Get-Service "SplunkForwarder").StartType -eq "Automatic") { 
        Write-Host "[+] Splunk is starting automatically" 
    }
    else { 
        Write-Host "[+] Splunk is not starting automatically"
        Write-Host "[+] Changing so Splunk starts automatically"
        Set-Service "SplunkForwarder" -StartupType Automatic
        if ((Get-Service "SplunkForwarder").StartType -eq "Automatic") {
            Write-Host "[+] Splunk is now starting automatically" 
        }
    } 

}
else {
    Write-Host "[+] Looks like everything's fine, not doing anything 😎"
}