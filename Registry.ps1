# Problem:   We need a way to add, read, edit, or delete a registry key

# Solution:  Use teh ItemProperty cmdlet in Powershell

# PowerShell Registry access - Priv required
# Written by Jeremy Martin - jeremy@informationwarfarecenter.com
# For more episodes of Cyber Secrets, visit youtube.com/IWCCyberSec
# www.informationwarfarecenter.com or Intelligenthacking.com

clear
$source = "http://informationwarfarecenter.com/IWC.jpg"
$destination = "$env:TEMP\IWC.jpg"
$RunKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
$WallPaper = "HKCU:\Control Panel\Desktop"

#download with invoke-webrequest
Invoke-WebRequest $source -OutFile $destination

#run the program Invoke-Item
Invoke-Item $destination

#Add a registry key - Start up program
new-itemproperty $RunKey -name StartMe -value $destination

# Read the value
$test = Get-ItemProperty $RunKey
$test.StartMe

# Change registry key
Set-ItemProperty $RunKey -Name StartMe -Value "nodode.exe"

# Remove registry key
Remove-ItemProperty $RunKey -name StartMe 




# Quick Wallpaper changer
Set-ItemProperty $WallPaper -Name Wallpaper $destination
Start-Sleep -s 10
rundll32.exe user32.dll, UpdatePerUserSystemParameters, 0, $false