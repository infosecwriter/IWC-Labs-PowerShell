# Problem: We need to get the names on the remote server for password auditing

# Solution: Write a Powershell script to remotely grab the usernames and save 
# them to a text file for a password cracker

# build a clean array called $results
$results = @()

# Set the dictionary name we want to use
$Report = "Names.txt"

# Prompt for the IP address we want to target
$HostName = Read-Host -Prompt "Please Enter the target the you want to search (Example: 192.168.0.1)"

# Reuse the code from before
$adsi = [ADSI]"WinNT://$HostName"
$adsi.Children | where {$_.SchemaClassName -eq 'user'} | Foreach-Object {
    $groups = $_.Groups() | Foreach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
    $_ | Select-Object @{n='UserName';e={$_.Name}},@{n='Groups';e={$groups -join ';'}}

# If the name is empty, move on
    if ($_.Name -icontains "---"){
    } else {

# If the name contains content, add it to the array
        Select-Object -unique
        $results += New-Object PSObject $_.Name
    }
}

# Export the data from the array to the dictionary
$results | Out-File $Report

# Open up the dictionary for inspection
Invoke-Item $Report