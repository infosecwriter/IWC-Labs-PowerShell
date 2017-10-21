clear
$results=@()
$Subnet = Read-Host -Prompt "Please Enter the Subnet the you want to search in (Example: 192.168.0)"
$IPStart = Read-Host -Prompt "Please Enter the First IP in that range (Example:1)"
$IPEnd = Read-Host -Prompt "Please Enter the Last IP in that range (Example:255)"
$Report = "$Subnet-report.csv"
if (Test-Path "$Report") {
    $results += Import-Csv -Path "$Report"

    foreach ($element in $results) {

        If (Test-Connection -count 1 -comp $element.ComputerName -quiet) {
            echo $element.ComputerName "is still online"
            $element.Online = "Still online"
            } else {
            $element.Online = "No"
            }
    }
} else {

    $IPStart..$IPEnd | %{
    $IP = "$Subnet.$_"
        If (Test-Connection -count 1 -comp $IP -quiet) {
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
            }
    }
}

$results | export-csv -Path "$Report" -NoTypeInformation
Invoke-Item "$Report"