# Problem:  We need a way to test open sockets in Powershell.  It would be nice to grab a banner
#           while we were at it too.

# Solution: create a function that will build a System.Net.Sockets.TCPClient and connect to the port.
#           If the port is open, attempt to grab the banner and if closed it will tell you.  

# TCP Connect test and banner grab.
# Written by Jeremy Martin - jeremy@informationwarfarecenter.com
# For more episodes of Cyber Secrets, visit youtube.com/IWCCyberSec
# www.informationwarfarecenter.com or Intelligenthacking.com

# To Create a function that connects to port and returns the response
function QueryPort ([string]$HostName, [string]$Port) { 
    # We want to create initial TCP Client  
    $socket = New-Object System.Net.Sockets.TCPClient
    # We will test the client on a target system and port
    $connected = ($socket.BeginConnect( $HostName, $Port, $Null, $Null )).AsyncWaitHandle.WaitOne(500)
    # If connected = true, query the socket to see what it has to say.
    if ($connected -eq "True"){
        $stream = $socket.getStream() 
        # Wiat just a little in case the socket is a litle slow to respond
        Start-Sleep -m 500; $text = ""
        # Be a good friend and listen to what the socket has to say.  
        while ($stream.DataAvailable) { $text += [char]$stream.ReadByte() }
        if ($text.Length -eq 0){ $text = "No Banner Given"}
        # Add a value to return when the function is done
        $text = "TCP:$Port is open : $text"
        $text
        # Close the connection
        $socket.Close()
    } else { # If the connection failed, do nothing 
    }
}

QueryPort 127.0.0.1 902
QueryPort intelligenthacking.com 21
QueryPort intelligenthacking.com 22
QueryPort intelligenthacking.com 80
QueryPort google.com 443

$TestPort = QueryPort 127.0.0.1 902
$TestPort


#Identify
$HostName = "127.0.0.1"
$Port = "443"