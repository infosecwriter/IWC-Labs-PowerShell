clear
$results=@()
$Subnet = Read-Host -Prompt "Please Enter the Subnet the you want to search in (Example: 192.168.0)"
$IPStart = Read-Host -Prompt "Please Enter the First IP in that range (Example:1)"
$IPEnd = Read-Host -Prompt "Please Enter the Last IP in that range (Example:255)"
$Report = "$Subnet-report.csv"

if (Test-Path "$Report") {
    $results += Import-Csv -Path "$Report"
    foreach ($element in $results) {
        $HostName = $element.IPAddress
        $Ping = New-Object System.Net.NetworkInformation.Ping  
        $Test = $Ping.send($HostName)
        if ($Test.Status -eq "Success"){
            $element.Online = "Still online"
            $element.IPAddress
        } else { $element.Online = "No"; echo $element.IPAddress "Offline" }
    }

} else {

    $IPStart..$IPEnd | %{
        $IP = "$Subnet.$_"
        $Ping = New-Object System.Net.NetworkInformation.Ping  
        $Test = $Ping.send($IP)
        if ($Test.Status -eq "Success"){
            $HostName = [System.Net.Dns]::GetHostByAddress($IP).HostName
	        $HostName = $HostName.trimend(".domain")     
            echo "$IP - $Hostname"
            $details = @{            
                Date             = get-date              
                ComputerName     = $Hostname                 
                IPAddress        = $IP
                Online           = "Yes" 
            }                           
            $results += New-Object PSObject -Property $details  
        } else { echo "$IP ***" }
    }
}


$results | export-csv -Path "$Report" -NoTypeInformation
Invoke-Item "$Report"