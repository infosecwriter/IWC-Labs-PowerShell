# Cyber Secrets Archiver (YouTube-DL, FFMPEG, & Cyber Secrets)
# Author: Jeremy Martin
# jeremy@informationwarfarecenter.com

# Building the Cyber Secrets video pack
Function Cleanup () {
    $MoveEpisodes = Get-ChildItem -Filter "*.mp4"
    foreach ($Episode in $MoveEpisodes) {
        if ($Episode.Name -imatch "Just"){ Move-Item $Episode "$CSPath\Just the Tip" -Force
        } else { Move-Item $Episode "$CSPath\Cyber Secrets" -Force }
    }
}

Function YouTube-dl ([string]$Path) {
    $source = "https://yt-dl.org/latest/youtube-dl.exe"
    $destination = "$Path\youtube-dl.exe"
    if (Test-Path $destination) { echo "YouTube-DL is already installed"
    } else { Invoke-WebRequest $source -OutFile $destination; echo "YouTube-dl Installed"}
}

Function FFMpeg ([string]$Path) {
    $Source = "http://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-3.3.2-win64-static.zip" 
    $destination = "$env:TEMP\ffmpeg.zip"
    $FFMpeg = "ffmpeg.exe"
    if (Test-Path "$destination\$FFMpeg") { echo "FFMpeg is already installed"
    } else { 
        curl $Source -OutFile $destination
        Expand-Archive –Path $destination -DestinationPath $Path -Force
        Move-Item "$Path\ffmpeg-3.3.2-win64-static\bin\*.*" $Path
        Remove-Item "$Path\ffmpeg-3.3.2-win64-static\" -Recurse -Force
        echo "FFMpeg installed"
    }
}

$CSPath = "c:\Cyber-Secrets"; clear
if (Test-Path $CSPath) {
    echo "Thank you for your support.  Enjoy the vids!"
} else { New-Item $CSPath -type directory }
if (Test-Path "$CSPath\Just the Tip") { } else { New-Item "$CSPath\Just the Tip" -type directory }
if (Test-Path "$CSPath\Cyber Secrets") { } else { New-Item "$CSPath\Cyber Secrets" -type directory }

# Download Youtube-dl, FFMpeg, and Cyber Secrets Just the Tip episodes
if (Test-Path "$CSPath\youtube-dl.exe") { echo "YouTube-DL is installed." } else { YouTube-dl $CSPath  -Verbose }
if (Test-Path "$CSPath\ffmpeg.exe") { echo "FFMpeg is installed." } else { FFMpeg $CSPath  -Verbose }

# Profit
echo "Starting the download"
Set-Location -Path $CSPath
$downloadme = "youtube-dl.exe" # --yes-playlist --recode-video mp4
$arguments = " https://www.youtube.com/watch?v=tHFhB-7LHls&list=PL9OxrA7zP_Z9a18ZA8KaNJdQ5u_6EZ7YU --yes-playlist --recode-video mp4"
start-process $downloadme $arguments -Wait -Verbose; Cleanup
# $arguments = " https://www.youtube.com/playlist?list=PL9OxrA7zP_Z8ZAc5cYJiQAx7SYkrvoUbh --yes-playlist --recode-video mp4"
# start-process $downloadme $arguments -Wait -Verbose; Cleanup
Invoke-Item $CSPath