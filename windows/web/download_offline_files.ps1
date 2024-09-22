Function Get-File {
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
    if (!(Test-Path $DirectoryName)) {
        [void](New-Item $DirectoryName -ItemType directory -Force)
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
$DestDir = New-Item (& { $Env:WINDOWS_OFFLINE_FILES_DIR ?? "offline-files" }) -ItemType directory -Force
Write-Output "Output directory set to ""$DestDir"""

$ServerVersion = "v0.12.1"
$DriverVersion = "v0.2.2"
$FeederVersion = "v0.2.11"

$SharedDir = New-Item (Join-Path $DestDir "shared") -ItemType directory -Force
$VersionDir = New-Item (Join-Path $DestDir $ServerVersion) -ItemType directory -Force

$ServerFile = Join-Path $VersionDir "SlimeVR-win64.zip"
$WebView2File = Join-Path $SharedDir "MicrosoftEdgeWebView2RuntimeInstaller.exe"
$JavaFile = Join-Path $SharedDir "OpenJDK17U-jre_x64_windows_hotspot_17.0.10_7.zip"
$DriverFile = Join-Path $VersionDir "slimevr-openvr-driver-win64.zip"
$FeederFile = Join-Path $VersionDir "SlimeVR-Feeder-App-win64.zip"

Get-File -Uri "https://github.com/SlimeVR/SlimeVR-Server/releases/download/$ServerVersion/SlimeVR-win64.zip" -OutFile $ServerFile
Get-File -Uri "https://go.microsoft.com/fwlink/p/?LinkId=2124703" -OutFile $WebView2File
Get-File -Uri "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10%2B7/OpenJDK17U-jre_x64_windows_hotspot_17.0.10_7.zip" -OutFile $JavaFile
Get-File -Uri "https://github.com/SlimeVR/SlimeVR-OpenVR-Driver/releases/download/$DriverVersion/slimevr-openvr-driver-win64.zip" -OutFile $DriverFile
Get-File -Uri "https://github.com/SlimeVR/SlimeVR-Feeder-App/releases/download/$FeederVersion/SlimeVR-Feeder-App-win64.zip" -OutFile $FeederFile

Copy-Item @($JavaFile, $WebView2File, $ServerFile, $DriverFile, $FeederFile) $DestDir -Force
