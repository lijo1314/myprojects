#!/bin/bash

# This script is to be used on both Linux and OSX devices to deploy Splunk
# The script also tries to make sure that the configuration and the version of Splunk is correct

main () {
    declare_variables
    echo "[+] hostname is: $HOSTNAME"
    echo "[+] going to install Splunk from: $file"
    if [[ -d "/Applications/SplunkForwarder" ]]; then
        echo "[+] old deployment of Splunk exists! Time to eradicate it"
        if pgrep -q splunkd; then
            echo "[+] stopping Splunk"
            /Applications/SplunkForwarder/bin/splunk stop
        fi
        echo "[+] nuking old Splunk"
        rm -rf /Applications/SplunkForwarder
        echo "[+] installing new Splunk"
        download_splunk
        install_splunk
        start_splunk
        splunk_config
    elif [[ -f "$splunk_binary" ]]; then
        echo "[+] Splunk binary exists at: $splunk_binary"
        check_splunk_version
        if [[ $old_splunk == true ]]; then
            echo "[+] Upgrade Splunk to newest version"
            upgrade_splunk
        fi
        start_splunk
        splunk_config
    else 
        echo "[+] Splunk binary doesn't seem to exist, will attempt to install Splunk"
        download_splunk
        install_splunk
        if [[ "$os_type" == "Linux" ]]; then
            create_splunk_user
        fi
        start_splunk
        splunk_config
    fi
}

upgrade_splunk () {
    echo "[+] starting Splunk upgrade"
    if pgrep -q splunkd; then
        echo "[+] stopping Splunk"
        /opt/splunkforwarder/bin/splunk stop
    fi
    download_splunk
    install_splunk
}

download_splunk () {
    echo "[+] attempting to download Splunk tgz archive"
    if [[ "$os_type" == "Darwin" ]]; then
        curl -o "$file" "$osx_installer"
    elif [[ "$os_type" == "Linux" ]]; then
        curl -o "$file" "$linux_installer"
    fi 
}

install_splunk () {
    echo "[+] attempting to install Splunk"
    if [[ $retry_counter -eq 2 ]]; then
        echo "[+] retry limit reached panicking!"
        exit
    fi
    echo "[+] sanity check to make sure archive exists"
    if [[ -f "$file" ]]; then
        echo "[+] archive exists, unpacking"
        tar xzf $file -C /opt/
    else
        echo "[+] somehow the archive doesn't exist, trying to download again"
        ((retry_counter++))
        download_splunk
        install_splunk
    fi
}

move_to_local () {
    if [[ "$(find /opt/splunkforwarder/etc/system/local -type f ! -name "README" | wc -l | xargs)" -gt 0 ]]; then
        echo "[+] found system/local files, attempting to move"
        if [[ $first_start == true ]]; then
            echo "[+] first time Splunk starts, waiting for it to properly startup"
            while ! grep -Fq lmpool /opt/splunkforwarder/etc/system/local/server.conf; do
                if [[ $config_check_counter -gt 30 ]]; then
                    echo "[+] its taking way longer that we'd like for Splunk to properly start, panicking!"
                    exit
                fi
                echo "[+] I don't see a specific line in the config, waiting"
                ((config_check_counter++))
                sleep 1 
            done
            if grep -Fq lmpool /opt/splunkforwarder/etc/system/local/server.conf; then
                if [[ $first_start == false ]]; then
                    echo "[+] catching a weird edge case where config was moved before Splunk had chance to properly start"
                    echo /opt/splunkforwarder/etc/system/local/server.conf >> /opt/splunkforwarder/etc/apps/zzz_system_local_copy/local/server.conf
                    rm /opt/splunkforwarder/etc/system/local/server.conf
                fi
            fi
            find /opt/splunkforwarder/etc/system/local -type f ! -name "README" -exec mv {} /opt/splunkforwarder/etc/apps/zzz_system_local_copy/local \;
            moved_config=true
        fi
    else
        echo "[+] no system/local files to move"
    fi
}

check_if_file_exist () {

    if [[ ! -f "/opt/splunkforwarder/etc/apps/$2" ]]; then
        echo "[+] creating /opt/splunkforwarder/etc/apps/$2"
        echo "$1" > /opt/splunkforwarder/etc/apps/$2
        moved_config=true
    elif [[ $(shasum -a 256 /opt/splunkforwarder/etc/apps/$2 | awk '{print $1}') != $(echo "$1" | shasum -a 256 | awk '{print $1}' ) ]]; then
        if [[ "$2" == "zzx_push_config_and_certs/local/server.conf" ]] || [[ "$2" == "zzx_push_config_and_certs/local/outputs.conf" ]]; then
            if [[ $(shasum -a 256 /opt/splunkforwarder/etc/apps/zzx_push_config_and_certs/files/AWSUFCombined.pem | awk '{print $1}') == $(echo "$AWSUFCombined_pem" | shasum -a 256 | awk '{print $1}' ) ]] &&
             grep -q "#config 2023-08" /opt/splunkforwarder/etc/apps/zzx_push_config_and_certs/local/server.conf; then
                echo "[+] newest version of config, not overwriting /opt/splunkforwarder/etc/apps/$2"
                return 1
            fi  
        fi
        echo "[+] hash doesn't match overwriting /opt/splunkforwarder/etc/apps/$2"
        echo "$1" > /opt/splunkforwarder/etc/apps/$2
        moved_config=true    
    else 
        echo "[+] /opt/splunkforwarder/etc/apps/$2 file already exists"
    fi
}

drop_config_and_certs () {

    echo "[+] checking the config files and certs"
    check_if_file_exist "$deploymentclient_conf" zzx_push_config_and_certs/local/deploymentclient.conf
    check_if_file_exist "$outputs_conf" zzx_push_config_and_certs/local/outputs.conf
    check_if_file_exist "$server_conf" zzx_push_config_and_certs/local/server.conf
    check_if_file_exist "$AWSUFCombined_pem" zzx_push_config_and_certs/files/AWSUFCombined.pem
    check_if_file_exist "$aws_ca_cert_pem" zzx_push_config_and_certs/files/AWS_CA_Cert.pem
    check_if_file_exist "$salty_ident" lgc_salty/local/deploymentclient.conf

}

start_splunk () {
    if [[ "$(pgrep -lf "^splunkd -p" | wc -l)" -gt 1 ]]; then
        echo "[+] multiple splunkd processes running, this shouldn't happen, killing them all"
        /opt/splunkforwarder/bin/splunk stop 
        killall splunkd
    fi
    if [[ ! -f "/opt/splunkforwarder/etc/instance.cfg" ]]; then
        echo "[+] starting Splunk for first time"
        /opt/splunkforwarder/bin/splunk start --accept-license --auto-ports --no-prompt --answer-yes --gen-and-print-passwd
        /opt/splunkforwarder/bin/splunk enable boot-start
        first_start=true
    elif pgrep -q splunkd; then
        echo "[+] Splunk is already running"
    else
        echo "[+] starting Splunk"
        /opt/splunkforwarder/bin/splunk start --no-prompt --answer-yes --accept-license
    fi
}

splunk_config () {

    echo "[+] attempting to check config of Splunk and make sure that necessary files are present"

    if [[ -d "/opt/splunkforwarder/etc/apps/zzz_system_local_copy/local" ]]; then
        echo "[+] directory with system/local contents exits, not creating"
        move_to_local
    else
        echo "[+] creating the directory for system/local content"
        mkdir -p  /opt/splunkforwarder/etc/apps/zzz_system_local_copy/local
        move_to_local
    fi

    if [[ -d  "/opt/splunkforwarder/etc/apps/zzx_push_config_and_certs" ]]; then
        echo "[+] directory holding certs and config exists"
        drop_config_and_certs
    else
        echo "[+] creating the directory holding certs and configs"
        mkdir -p /opt/splunkforwarder/etc/apps/zzx_push_config_and_certs/files /opt/splunkforwarder/etc/apps/zzx_push_config_and_certs/local
        drop_config_and_certs
    fi

    if [[ -d  "/opt/splunkforwarder/etc/apps/lgc_salty" ]]; then
        echo "[+] directory holding ident and config exists"
        drop_config_and_certs
    else
        echo "[+] creating the directory holding certs and configs"
        mkdir -p /opt/splunkforwarder/etc/apps/lgc_salty/local
        drop_config_and_certs
    fi

    #echo "[+] did we move config: $moved_config"
    if [[ $moved_config == true ]]; then
        echo "[+] restarting Splunk so config applies, first restart might take a little while"
        /opt/splunkforwarder/bin/splunk restart --no-prompt --answer-yes --accept-license
    fi
}

create_splunk_user () {
    echo "[+] checking if splunk user exists"
    if grep -c '^splunk:' /etc/passwd; then
        echo "[+] splunk user exists"
    else
        echo "[+] splunk user doesn't exist, creating"
        groupadd splunk
        useradd -d /opt/splunkforwarder -g splunk -s /bin/bash -c "Splunk Server" splunk
    fi
}

check_splunk_version () {
    echo "[+] checking current Splunk version"
    if [[ -f "$splunk_binary" ]]; then
        echo "[+] Splunk binary exists"
        splunk_version=$(/opt/splunkforwarder/bin/splunk -version --no-prompt --answer-yes --accept-license | awk '{print $4}')
        echo "[+] Splunk version is: $splunk_version"
        echo "[+] Splunk version from installer is: $installer_version"
        if [ $(ver $splunk_version) -lt $(ver $installer_version) ]; then
            echo "[+] current version is lower"
            old_splunk=true
        fi
    fi
}

function ver { printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' '); }

declare_variables () {
    file="/tmp/splunkforwarder.tgz"
    splunk_binary="/opt/splunkforwarder/bin/splunk"
    splunk_tgz_hash=""
    retry_counter=0
    moved_config=false
    first_start=false
    config_check_counter=0
    os_type="$(uname -s)"
    osx_installer='https://download.splunk.com/products/universalforwarder/releases/9.1.2/osx/splunkforwarder-9.1.2-b6b9c8185839-darwin-universal2.tgz'
    linux_installer='https://download.splunk.com/products/universalforwarder/releases/9.1.2/linux/splunkforwarder-9.1.2-b6b9c8185839-Linux-x86_64.tgz'
    installer_version="$(echo "$linux_installer"| awk -F/ '{print $7}')"

    deploymentclient_conf=$(cat << EOF 
[target-broker:deploymentServer]
targetUri = s-edge.security.letsgetchecked.com:8089
EOF
)

    outputs_conf=$(cat << EOF
[tcpout]
defaultGroup = default-autolb-group

[tcpout:default-autolb-group]
server = s-hf.security.letsgetchecked.com:9997
clientCert = \$SPLUNK_HOME/etc/apps/zzx_push_config_and_certs/files/AWSUFCombined.pem
sslPassword = 6foRGhvNRxWjKt2wycXmvz7fFT9qHnP9
useSSL = true
useACK = false
sslVerifyServerCert = true
sslCommonNameToCheck = s-hf.security.letsgetchecked.com
EOF
)

    server_conf=$(cat << EOF
#config 2023-08
[general]
serverName = \$HOSTNAME

[sslConfig]
sslPassword = 6foRGhvNRxWjKt2wycXmvz7fFT9qHnP9
sslRootCAPath = \$SPLUNK_HOME/etc/apps/zzx_push_config_and_certs/files/AWS_CA_Cert.pem
serverCert = \$SPLUNK_HOME/etc/apps/zzx_push_config_and_certs/files/AWSUFCombined.pem
sslVerifyServerCert = true
sslCommonNameToCheck = s-edge.security.letsgetchecked.com
EOF
)

    aws_ca_cert_pem=$(cat << EOF 
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
-----END CERTIFICATE-----
EOF
)

    AWSUFCombined_pem=$(cat << EOF
-----BEGIN CERTIFICATE-----
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
-----END CERTIFICATE-----
EOF
)

    salty_ident=$(cat << EOF
[deployment-client]
clientName = jumpcloud
EOF
)
}

main