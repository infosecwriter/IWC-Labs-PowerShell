# Local account push for .exe using powershell and PsExec.exe
# Written by Jeremy Martin - jeremy@informationwarfarecenter.com
#
# Top two lines contais the IP address range to target
# $HostName = IP address converted to system name
# $DomainUser param = -u $HostName/user
# $Pass = -p password
# $Args contains .exe to push
clear
$results = @()
$details = @()
$Subnet = Read-Host -Prompt "Please Enter the Subnet the you want to search in (Example: 192.168.0)"
$IPStart = Read-Host -Prompt "Please Enter the First IP in that range (Example:1)"
$IPEnd = Read-Host -Prompt "Please Enter the Last IP in that range (Example:255)"
$Domain = Read-Host -Prompt "Please Enter the Domain (NA for None)"
$ScriptPath = "c:\"
$Prog = Read-Host -Prompt "Please Enter the program to push"
$Method = Read-Host -Prompt "Please Enter the distribution method. (1. PsExec [Requires UAC Disabled on remote] - 2. PSSession [Remote Powershell is required] - 3. WMI)"
$Report = "$Subnet.$IPStart-$IPEnd-report.csv"
$User = Read-Host -Prompt "Please Enter the Admin User"
$Pass = Read-Host -Prompt "Please Enter the Admin Pass"
$tempFolder=$Env:TEMP
clear
echo "Scanning $Subnet.$IPStart-$IPEnd"
echo "Domain: $Domain"
echo "User: $User"
Echo "Program: $Prog"

if (Test-Path $Report) {
 $results += Import-Csv -Path $Report
}

echo "Starting the push now..."


$IPStart..$IPEnd | %{
    $IP = "$Subnet.$_"
    If (Test-Connection -count 3 -comp $IP -quiet) {
	    $HostName = [System.Net.Dns]::GetHostByAddress($IP).HostName
	    $HostName = $HostName.trimend(".domain") 
        if ($Domain -eq "NA"){
            $Domain=$HostName
        } 
        $cmdkeyParams = @('/add:$HostName /user:$Domain\$User /pass:$Pass') 
        Start-Process -FilePath cmdkey.exe -ArgumentList "$cmdkeyParams" -wait    
	    echo "$IP - $HostName"   
        $details = @{            
            Date             = get-date              
            ComputerName     = $Hostname                 
            IPAddress        = $IP
            Method           = "" 
            Install          = ""
            Copied          = ""
        }
        If ($Method -eq 1){
# Method 1 is a PsExec push
            $Target = "\\$HostName"
            $PUser = "-u $Domain\$User"
            $PPass = "-p $Pass"
	        $Args = @('-i -f -c', $Prog)
	        $Exec = "./PsExec.exe"
            $Params = "$Target $PUser $PPass $Args"
            $details.Method = "PsExec" 
	        echo "$Exec $Params"
            $process = Start-Process -FilePath "$Exec" -ArgumentList "$Params" -PassThru
            Wait-Process -InputObject $process
            if ($process.ExitCode -eq 0) {       
                $details.Install = "Successful"
                $details.Copied = "Yes"
                echo "$Prog was pushed to $IP - $HostName"
                New-Object -TypeName psobject -Property $props
            } elseif ($process.ExitCode -eq 2){
                $details.Install = "Copied but cancelled locally"
                $details.Copied = "Yes"                
                echo "$Prog was pushed to $IP - $HostName"
            } else {
                $details.Install = "Failed"
                $details.Copied = "No"                
                echo "$Prog FAILED to push to $IP - $HostName"
            }
 

        } ElseIf ($Method -eq 2){
# Method 2 is a PSSession push
            $Target = "\\$HostName\c$"
            $details.Method           = "PSSession" 
	        echo "Remote copy & run.  Attempting to copy data now"
            if (Test-Path "$Target\$Prog"){ 
                echo "Found it on the other side"
                Remove-Item -Path "$Target\$Prog" -Force  -Verbose
            }
            Try
            {
                Copy-item $Prog -Destination $Target -PassThru -Force -Verbose
                echo "$Prog copied to $IP - $HostName"     
                $details.Copied = "Yes"
            } Catch {
                echo "Failed to copy $Prog to $HostName."
                $details.Copied = "No"
            }

            Try
            {
                $secpasswd = ConvertTo-SecureString $Pass -AsPlainText -Force
                $mycreds = New-Object System.Management.Automation.PSCredential ($User, $secpasswd)
                $ScriptBlock = [ScriptBlock]::Create("$ScriptPath\$Prog");
                $session = New-PSSession -ComputerName $HostName -credential $mycreds
                echo "Attempting Session on $IP - $HostName"
                Invoke-Command -Session $session -ScriptBlock $ScriptBlock -Verbose
                echo "Successfully connected to remote server."
                # remove-pssession -session $session  -Verbose
                echo "$Prog running on $IP - $HostName"
                $details.Install = "Successful"
                
            } Catch {
                echo "$Prog Failed to push to $IP - $HostName"
                $details.Install          = "Failed"
            }
            echo "Finished with $HostName"
            

        } ElseIf ($Method -eq 3){
# Method 3 is a WMI push
            echo "WMI push initiated"
            $details.Method           = "WMI" 
            $Target = "\\$HostName\c$"
	        echo "Remote copy & run.  Attempting to copy data now"
            if (Test-Path "$Target\$Prog"){ 
                echo "Found it on the other side"
                Remove-Item -Path "$Target\$Prog" -Force -Verbose
            }

            Try {
                Copy-item $Prog -Destination $Target -PassThru -Force -Verbose
                echo "$Prog copied to $IP - $HostName"
                $details.Copied = "Yes"
            } Catch {
                echo "Failed to copy $Prog to $HostName."
                $details.Copied = "No"
            }

            Try {
                $RemoteStartInstall = ([WMICLASS]"\\$HostName\ROOT\CIMV2:win32_process").Create("$ScriptPath\$Prog")
#                $Action = { if ($EventArgs.NewEvent.ProcessID -eq $RemoteStartInstall.ProcessId) { 
#                    echo "Remote Install"
#                    # Remove-Item $ScriptPath
#                    Unregister-Event -SourceIdentifier Install
#                    Get-Job -Name Install | Stop-Job -PassThru | Remove-Job -Force
#                    }
#                }
#                Register-WmiEvent -SourceIdentifier Install -ComputerName $HostName -Class Win32_ProcessStopTrace -Action $Action
                $details.Install = "Successful"
                
            } Catch {
                echo "Remote Install failed"
                $details.Install = "Failed"
            }


        }
        $cmdkeydParams = @('/delete:$HostName') 
        if ($Domain -eq $HostName){
            $Domain="NA"
        } else {
               
        }
        $results += New-Object PSObject -Property $details
    } else {
        Write-Host "the $IP is not reachable"
    }
    
}


$results | export-csv -Path $Report -NoTypeInformation -Force
Invoke-Item $Report
