# Problem: We need to make an MD5 hash of a directory of files

# Solution:  Use Get-FileHash -Algorithm MD% and loop it from the results of Get-ChildItem

# MD5 Hashing script.
# Written by Jeremy Martin - jeremy@informationwarfarecenter.com
# For more episodes of Cyber Secrets, visit youtube.com/IWCCyberSec
# www.informationwarfarecenter.com or Intelligenthacking.com

clear
$results = @(); $details = @(); $results = @() # setting up arrays
$Path = Read-Host -Prompt "Please Enter the Folder to hash" #request the location to Hash
$Report = "MD5-Hash-report.csv" # Set the Report name
Set-Location -Path $Path # Go to the location in $Path

$HashMe = Get-ChildItem -Filter "*.*" # Get the contents of a folder
foreach ($Strain in $HashMe) { # Loop through each file in the array $HashMe
    $SubStrain = Get-FileHash -Algorithm MD5 -Path $Strain # Using Get-FileHash with the MD5 for file
    $details = @{ # Setting up the array that contains date, file name, and the MD5 Hash
        Date = get-date
        FileName = $SubStrain.Path
        MD5 = $SubStrain.Hash 
    }
    if ($SubStrain.Path.Length -gt 0){ 
        # If the filename is not empty, add the file + hash to the array $results
        $results += New-Object PSObject -Property $details
    }
}

$results | Export-Csv -Encoding ASCII -NoTypeInformation -Path $Report # Save to CSV $Report
$results
Invoke-Item $Report # Open CSV $Report