# Problem:  We needed a method to encode and decode either files or text easily

# Solution: We decided to create a powershell script to do both using the ToBase64String, IO.File, 
# System.Text.Encoding, and Convert options.  There is even a pretty little popup box to pic the 
# file using System.Windows.Forms.OpenFileDialog

# Written by Jeremy Martin, Information Warfare Center
# More tips and episodes of Cyber Secrets at:  
# YouTube.com/IWCCyberSec
# InformationWarfareCenter.com
# IntelligentHacking.com

Clear; $Method = Read-Host -Prompt "Would you like to Encode (1) or Decode (2)"

If ($Method -eq 1 ){
    $EncodeME = Read-Host -Prompt "File (1) or Text (2)"
    if ($EncodeME -eq 1 ){
            $FileName = Get-FileName
            $EncodedData = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FileName)) | Out-File "$FileName.b64"
            echo "$FileName.b64 has been created!"
        } elseif ($EncodeME -eq 2 ){
            $Text = Read-Host -Prompt "Enter the Text to Encode"
            $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
            $EncodedText =[Convert]::ToBase64String($Bytes)
            $EncodedText
        }

} elseif ($Method -eq 2 ){
    $DecodeME = Read-Host -Prompt "File (1) or Text (2)"
    if ($DecodeME -eq 1 ){
        $FileName = Get-FileName
        $EncodedData = Get-Content $FileName -Raw 
        $DFileName = Read-Host -Prompt "What is the new filename?"
        $DecodedData = [IO.File]::WriteAllBytes($DFileName, [Convert]::FromBase64String($EncodedData))
        $msgBoxInput =  Read-Host -Prompt "Open or test the file (Y)?"
        if  ($msgBoxInput -eq "Y" ) { 
            Start-Process $DFileName 
        } else { 
            return
        }
    } elseif ($DecodeME -eq 2 ){
        $EncodedText = Read-Host -Prompt "Enter the Text to Decode" 
        $DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($EncodedText))
        $DecodedText
    }
}

Function Get-FileName($initialDirectory){   
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "All files (*.*)| *.*"
    $OpenFileDialog.ShowDialog() | Out-Null
    $FileName = $OpenFileDialog.filename
    $FileName
}

