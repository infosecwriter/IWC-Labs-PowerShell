# Written by Jeremy Martin, Information Warfare Center
# More tips and episodes of Cyber Secrets at 
# YouTube.com/IWCCyberSec
# InformationWarfareCEnter.com
# IntelligentHacking.com

clear
$results=@()
$Subnet = Read-Host -Prompt "Please Enter the Subnet the you want to search in (Example: 192.168.0)"
$IPStart = Read-Host -Prompt "Please Enter the First IP in that range (Example:1)"
$IPEnd = Read-Host -Prompt "Please Enter the Last IP in that range (Example:255)"
$User = Read-Host -Prompt "Please Enter the Admin User"
$Pass = Read-Host -Prompt "Please Enter the Admin Pass"
$Domain = Read-Host -Prompt "Please Enter the Domain (NA for None)"
$ScriptPath = Read-Host -Prompt "Please Enter the destination path (Example: c:\)"
$Prog = Read-Host -Prompt "Please Enter the program to push"
echo "Starting the push now..."
if (Test-Path $Subnet-"results.csv")
{
    $results += Import-Csv -Path $Subnet-"results.csv"
}
$IPStart..$IPEnd | %{
    $IP = "$Subnet.$_"
    If (Test-Connection -count 1 -comp $IP -quiet) {
	    $HostName = [System.Net.Dns]::GetHostByAddress($IP).HostName
	    $HostName = $HostName.trimend(".domain") 
        if ($Domain -eq "NA"){
            $Domain=$HostName
        } 
        $cmdkeyParams = @('/add:$HostName /user:$Domain\$User /pass:$Pass') 
        Start-Process -FilePath cmdkey.exe -ArgumentList "$cmdkeyParams" -wait    
	    echo "$IP - $HostName"   
        $props = @{
            HostName = $HostName
            IPAddress = $ip
            Path = $ScriptPath
            Program = $Prog
        } 
        $Target = "\\$HostName"
        $PUser = "-u $Domain\$User"
        $PPass = "-p $Pass"
	    $Args = @('-i -f -c', $Prog)
	    $Exec = "./PsExec.exe"
        $Params = "$Target $PUser $PPass $Args"
	    echo "$Exec $Params"
        $process = Start-Process -FilePath "$Exec" -ArgumentList "$Params" -PassThru
        Wait-Process -InputObject $process
        if ($process.ExitCode -eq 0) {
            $results+= "$Prog was pushed to $IP - $HostName using PsExec."
            echo "$Prog was pushed to $IP - $HostName"
            New-Object -TypeName psobject -Property $props
        } elseif ($process.ExitCode -eq 2){
            $results+= "$Prog was pushed to $IP - $HostName"
            echo "$Prog was pushed to $IP - $HostName"
        } else {
            $results+= "$Prog FAILED to push to $IP - $HostName" 
            echo "$Prog FAILED to push to $IP - $HostName"
        }

    $cmdkeydParams = @('/delete:$HostName') 

    } else {
        Write-Host "the $IP is not reachable"
    }
}


$results >> $Subnet-"results.csv"
Invoke-Item $Subnet-"results.csv" -force