Function Download-File {
    Param (
        [Parameter(Mandatory = $True)] [System.Uri]$Uri,
        [Parameter(Mandatory = $True )] [string]$OutFile
    )

    # Create a FileInfo object out of the output file for reading and writing information
    [System.IO.FileInfo]$FileInfo = $OutFile
    # FileInfo works even if the file/directory doesn't exist,
    # which is better than Get-Item which requires the file to exist
    $FileName = $FileInfo.Name
    $DirectoryName = $FileInfo.DirectoryName

    # Make sure the destination directory exists
    if (!(Test-Path "$DirectoryName")) {
        [void](New-Item -Path "$DirectoryName" -Force -ItemType "directory")
    }

    try {
        Write-Output "Checking for ""$FileName""..."

        # Use HttpWebRequest to download file
        $WebRequest = [System.Net.HttpWebRequest]::Create($Uri);

        # If the file already exists
        if (Test-Path "$OutFile") {
            # Then add last modified info
            $WebRequest.IfModifiedSince = $FileInfo.LastWriteTime
        }

        $WebRequest.Method = "HEAD";
        [System.Net.HttpWebResponse]$WebResponse = $WebRequest.GetResponse()

        Write-Output "Downloading ""$FileName"" ($($WebResponse.ContentLength) bytes)..."

        # Download the file using a simpler method
        Invoke-WebRequest -Uri $Uri -OutFile $OutFile

        # Write the last modified time from the request
        $FileInfo.LastWriteTime = $WebResponse.LastModified

        Write-Output """$FileName"" has been downloaded"
    }
    catch [System.Net.WebException] {
        # Check for a 304 error (file not modified)
        if ($_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::NotModified) {
            Write-Output """$FileName"" is not modified, not downloading..."
        }
        else {
            # Unexpected error
            $Status = $_.Exception.Response.StatusCode
            $Msg = $_.Exception
            Write-Output "Error dowloading ""$FileName"", Status code: $Status - $Msg"
        }
    }
}

# Use download directory from environment variables, otherwise default to working directory
$DownloadDir = if ($Env:WINDOWS_OFFLINE_FILES_DIR) { $Env:WINDOWS_OFFLINE_FILES_DIR } else { "Offline_Files" }

Write-Output "Download directory set to ""$DownloadDir"""

Download-File -Uri "https://github.com/SlimeVR/SlimeVR-Server/releases/download/v0.12.1/SlimeVR-win64.zip" -OutFile "$DownloadDir\SlimeVR-win64.zip"
Download-File -Uri "https://go.microsoft.com/fwlink/p/?LinkId=2124703" -OutFile "$DownloadDir\MicrosoftEdgeWebView2RuntimeInstaller.exe"
Download-File -Uri "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10%2B7/OpenJDK17U-jre_x64_windows_hotspot_17.0.10_7.zip" -OutFile "$DownloadDir\OpenJDK17U-jre_x64_windows_hotspot_17.0.10_7.zip"
Download-File -Uri "https://github.com/SlimeVR/SlimeVR-OpenVR-Driver/releases/download/v0.2.2/slimevr-openvr-driver-win64.zip" -OutFile "$DownloadDir\slimevr-openvr-driver-win64.zip"
Download-File -Uri "https://github.com/SlimeVR/SlimeVR-Feeder-App/releases/download/v0.2.11/SlimeVR-Feeder-App-win64.zip" -OutFile "$DownloadDir\SlimeVR-Feeder-App-win64.zip"
