# The Problem:  We need to identify remote users and groups on the local systems of the network

# Solution: Write a Powershell script using ADSI and loop for specific data user data

# Local account and group query.
# Written by Jeremy Martin - jeremy@informationwarfarecenter.com
# For more episodes of Cyber Secrets, visit youtube.com/IWCCyberSec
# www.informationwarfarecenter.com or Intelligenthacking.com

clear
$results = @()
$Subnet = Read-Host -Prompt "Please Enter the Subnet the you want to search in (Example: 192.168.0)"
$IPStart = Read-Host -Prompt "Please Enter the First IP in that range (Example:1)"
$IPEnd = Read-Host -Prompt "Please Enter the Last IP in that range (Example:255)"
echo "Scanning $Subnet.$IPStart-$IPEnd"

$IPStart..$IPEnd | %{
    $IP = "$Subnet.$_"
    If (Test-Connection -count 3 -comp $IP -quiet) {
        $adsi = [ADSI]"WinNT://$IP"
        $adsi.Children | where {$_.SchemaClassName -eq 'user'} | Foreach-Object {
            $groups = $_.Groups() | Foreach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
            $_ | Select-Object @{n='UserName';e={$_.Name}},@{n='Groups';e={$groups -join ';'}}
        }
    } else {
        Write-Host "the $IP is not reachable"
    }
}


