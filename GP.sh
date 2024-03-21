#!/bin/bash
DownloadUrl="https://pan-gp-client.s3.amazonaws.com/6.2.1-132/GlobalProtect.pkg" 
############### Do Not Edit Below This Line ############### 
fileName="GlobalProtect.pkg" 
# Create Temp Folder
DATE=$(date '+%Y-%m-%d-%H-%M-%S') 
TempFolder="Download-$DATE" 
mkdir /tmp/$TempFolder 

# Navigate to Temp Folder 
cd /tmp/$TempFolder 

# Download File into Temp Folder 

curl -o "$fileName" "$DownloadUrl" 

installer -verboseR -package "/tmp/$TempFolder/$fileName" -target / 

# Remove Temp Folder and download 
rm -r /tmp/$TempFolder 

echo "Deleted /tmp/$TempFolder"