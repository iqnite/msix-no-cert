[CmdletBinding(PositionalBinding = $false)]
param (
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$inputFiles,
    [string]$config,
    [Alias("o")][string]$output,
    [Alias("c")][string]$cert,
    [Alias("t")][string]$title,
    [Alias("d")][string]$description,
    [Alias("i")][string]$icon,
    [Alias("v")][string]$version,
    [Alias("h")][switch]$help
)

if ($help -or (-not $output -or $inputFiles.count -lt 1) -and -not $config) {
    Write-Host "Usage: .\create_installer.ps1 <installer.msix installer.appinstaller ...> [-o <output folder>] [-c <certificate.cer>] [-t <title>] [-d <description>] [-i <icon.ico>] [-v <version>]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -o,  -output         Output path for the installer archives."
    Write-Host "  -c,  -cert           Path to the certificate file."
    Write-Host "  -t,  -title          Title of the installer."
    Write-Host "  -d,  -description    Description of the installer."
    Write-Host "  -i,  -icon           Path to the icon file for the installer."
    Write-Host "  -v,  -version        Version number for the installer."
    Write-Host "  -h,  -help           Display this help message."
    Write-Host "       -config         Path to a JSON configuration file, to be used instead of the above options."
    Write-Host ""
    Write-Host "Example:"
    Write-Host "  .\create_installer.ps1 installer.msix installer.appinstaller -o output -c certificate.cer -t 'Installer Title' -d 'Installer Description' -i icon.ico -v '1.0.0'"
    exit
}

if (-not (Get-Module -ListAvailable -Name PS2EXE)) {
    Install-Module -Name PS2EXE -Scope CurrentUser -Force
}

if ($config) {
    $configObj = Get-Content -Path $config -Raw | ConvertFrom-Json
}
else {
    $configObj = [PSCustomObject]@{
        input       = $inputFiles
        output      = $output
        cert        = $cert
        title       = $title
        description = $description
        icon        = $icon
        version     = $version
    }
}

New-Item -ItemType Directory -Path ".\installer" -Force | Out-Null

$embeddedInstallScript = @'
$scriptPath = $PSScriptRoot

$certPath = Get-ChildItem -Path $scriptPath -Filter *.cer | Select-Object -First 1 -ExpandProperty FullName
$installerPath = Get-ChildItem -Path $scriptPath -Filter installer.* | Select-Object -First 1 -ExpandProperty FullName

$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath)

$store = New-Object System.Security.Cryptography.X509Certificates.X509Store("TrustedPeople", "LocalMachine")
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()

Start-Process -FilePath $installerPath
'@

$installSourcePath = Join-Path $env:TEMP "yt-dlp-ui.install.ps1"
Set-Content -Path $installSourcePath -Value $embeddedInstallScript -Encoding UTF8

Invoke-PS2EXE `
    -InputFile $installSourcePath `
    -OutputFile ".\installer\install.exe" `
    -IconFile $configObj.icon `
    -title $configObj.title `
    -description $configObj.description `
    -version $configObj.version `
    -NoConsole `
    -RequireAdmin `
    -verbose
    
$7zipPath = "${env:ProgramFiles}\7-Zip\7z.exe"

if ($configObj.cert) {
    Copy-Item $configObj.cert "installer\certificate.cer" -Force
}

if (-not (Test-Path $7zipPath)) {
    Write-Host "7-Zip not found. Please install 7-Zip to continue." -BackgroundColor Red
    exit
}

for ($i = 0; $i -lt $configObj.input.count; $i++) {
    $zipPath = Join-Path $configObj.output "$(Split-Path $configObj.input[$i] -Leaf).zip"
    Write-Host "Creating archive for $($configObj.input[$i]) at $zipPath" -ForegroundColor Cyan
    $fileName = Split-Path $configObj.input[$i] -Leaf
    $extension = [System.IO.Path]::GetExtension($fileName)
    Copy-Item $configObj.input[$i] "installer\installer$extension" -Force
    Remove-Item $zipPath -ErrorAction SilentlyContinue
    Push-Location "installer"
    try {
        & $7zipPath a -tzip (Join-Path ".." $zipPath) "*"
    }
    finally {
        Pop-Location
    }

    Write-Host "Archive created at $zipPath" -ForegroundColor Blue
}

Remove-Item $installSourcePath -ErrorAction SilentlyContinue

Write-Host "$($configObj.input.count) installers created." -ForegroundColor Green
