$config = Get-Content -Path ".\assets\installer_config.json" -Raw | ConvertFrom-Json
Install-Module -Name PS2EXE -Scope CurrentUser
Invoke-PS2EXE `
    -InputFile ".\install.ps1" `
    -OutputFile ".\installer\install.exe" `
    -IconFile $config.IconFile `
    -title $config.Title `
    -description $config.Description `
    -version $config.Version `
    -NoConsole `
    -RequireAdmin `
    -verbose
    
$7zipPath = "${env:ProgramFiles}\7-Zip\7z.exe"
$zipPath = $config.OutputFile
# $sfxPath = "wyder_installer.exe"
# $configPath = "config.txt"

if (Test-Path $7zipPath) {
    Push-Location "installer"
    try {
        & $7zipPath a -tzip (Join-Path ".." $zipPath) "*"
    } finally {
        Pop-Location
    }

    # & $7zipPath a -sfx $sfxPath $zipPath `
    #     -config $configPath `
    #     -IconFile "wyder.ico" `
    #     -title "Wyder Video Downloader Installer" `
    #     -description "Installs the Wyder Video Downloader, an easy-to-use tool for downloading videos from various platforms."
    
    # Remove-Item $zipPath -Force

    Write-Host "Archive created at $zipPath" -ForegroundColor Green
}
else {
    # Fall back to .NET compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory("installer", $zipPath)
        
    Write-Host "7-Zip not found. Created standard zip archive at $zipPath" -ForegroundColor Yellow
    Write-Host "For a self-extracting archive, please install 7-Zip and run this script again." -ForegroundColor Yellow
}
