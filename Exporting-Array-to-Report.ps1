# Problem:   We need to export data gathered in Powershell to a file

# Solution:  There are several ways to do this, but we are going to focus on two specifically.
# Sample 1:  Check to see if a log has been created.  If so, load it into memory and then export 
#            the data in the array to a .CSV file to open in a spread sheet or import elsewhere.
# Sample 2:  Export only a specific column in an array to a text file.  I use this code to export
#            data into a dictionary for use in tools like Hydra, John the Ripper, and other tools.
# Append data to the array - $results += New-Object PSObject -Property $details

# Exporting to a file.
# Written by Jeremy Martin - jeremy@informationwarfarecenter.com
# For more episodes of Cyber Secrets, visit youtube.com/IWCCyberSec
# www.informationwarfarecenter.com or Intelligenthacking.com

# Sample 1
clear
$results1=@()
$Report1 = "info.csv"
$details = @{            
        Date             = get-date              
        ComputerName     = $env:COMPUTERNAME                 
        OS               = $env:OS
        UserName         = $env:USERNAME
        Domain           = $env:USERDOMAIN 
} 
if (Test-Path "$Report1") {
    $results1 += Import-Csv -Path "$Report1"
    echo "loading file $Report1"
    $results1 += New-Object PSObject -Property $details
} else { $results1 = New-Object PSObject -Property $details }
$results1 | export-csv -Path $Report1 -NoTypeInformation -Encoding ASCII
Invoke-Item $Report1

# Sample 2
clear
$results2 = @()
$Report2 = "Names.txt"
$adsi = [ADSI]"WinNT://192.168.0.34"
$adsi.Children | where {$_.SchemaClassName -eq 'user'} | Foreach-Object {
    $groups = $_.Groups() | Foreach-Object {
        $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
    }
    $_ | Select-Object @{n='UserName';e={$_.Name}},@{n='Groups';e={$groups -join ';'}}
    if ($_.Name -icontains "---"){
    } else {
        Select-Object -unique
        $results2 += New-Object PSObject $_.Name
    }
}
$results2 | Out-File $Report2 -Encoding ASCII # or utf8 utf7 utf32 etc
Invoke-Item $Report2