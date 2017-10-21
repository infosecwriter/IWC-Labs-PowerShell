# The problem:  We want to download episodes of Cyber Secrets from YouTube to view offfline

# Solution:     Use the tools YouTube-dl, FFMpeg, and a file that contains the links to the episode
#               we want to watch. 

# Video Archiver (YouTube-DL, FFMPEG, & Cyber Secrets)
# Author: Jeremy Martin
# jeremy@informationwarfarecenter.com

Function Cleanup () {
    $MoveEpisodes = Get-ChildItem -Filter "*.mp4"
    foreach ($Episode in $MoveEpisodes) { Move-Item $Episode "$FPath\Finished" -Force }
}

$FPath = "D:\Videos"; clear
$File = "$FPath\links.txt"
Set-Location -Path $FPath

if (Test-Path $FPath) {
} else { New-Item $FPath -type directory }
if (Test-Path "$FPath\Finished") {
    echo "Thank you for your support.  Enjoy the vids!"
} else { New-Item "$FPath\Finished" -type directory }

$source = "https://yt-dl.org/latest/youtube-dl.exe"
$destination = "$FPath\youtube-dl.exe"
if (Test-Path $destination) {
    echo "YouTube-DL is already installed."
} else { echo "Downloading Youtube-DL.exe"; Invoke-WebRequest $source -OutFile $destination }

$Source2 = "http://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-3.3.2-win64-static.zip" 
$destination2 = "$env:TEMP\ffmpeg.zip"
$FFMpeg = "ffmpeg.exe"
if (Test-Path $FFMpeg) {
    echo "FFMpeg is already installed."
} else { 
    echo "Downloading FFMpeg"
    curl $Source2 -OutFile $destination2
    Expand-Archive –Path $destination2 -DestinationPath $FPath -Force
    Move-Item "$FPath\ffmpeg-3.3.2-win64-static\bin\*.*" $FPath
    Remove-Item "$FPath\ffmpeg-3.3.2-win64-static\" -Recurse -Force
}

$links = Get-Content $File
$downloadme = "youtube-dl.exe" # --yes-playlist --recode-video mp4
foreach ($link in $links) {
    echo "downloading $link"
    $arguments = " $link --recode-video mp4"
    start-process $downloadme $arguments 
    Start-Sleep -s 10
}
Cleanup # Move episodes to correct folders
Invoke-Item $FPath