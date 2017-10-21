# IWC Custom PortableApps Builder
# Author: Jeremy Martin
# jeremy@informationwarfarecenter.com

# Download PortableApps and install
# Ask for where the PortableApps is installed
clear
$source = "https://portableapps.com/redirect/?a=PAcPlatform&t=http%3A%2F%2Fdownloads.portableapps.com%2Fportableapps%2Fpacplatform%2FPortableApps.com_Platform_Setup_14.4.1.paf.exe"
$destination = "$env:TEMP\installer.exe"
Invoke-WebRequest $source -OutFile $destination
Start-Process -FilePath "$destination" -PassThru
$PA = Read-Host -Prompt "Where did you install PortableApps (Example d:\PortableApps)"

# IWC Extra files
echo "Downloading IWC Extra Apps"
$Source2 = "https://www.informationwarfarecenter.com/files/IWC-Extra-Apps.zip" 
$destination2 = "$env:TEMP\IWC-Extras.zip"
curl $Source2 -OutFile $destination2
Expand-Archive –Path $destination2 -DestinationPath "$PA\PortableApps" -Force
Start-Process -FilePath "$PA\Start.exe" -PassThru