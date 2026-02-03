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

$ErrorActionPreference = "Stop"

Write-Host "Self-signed MSIX Packager" -ForegroundColor Cyan
Write-Host "Version 2.2.0" -ForegroundColor Cyan

$scriptName = ".\msix-no-cert.exe"

if ($help -or (-not $output -or $inputFiles.count -lt 1) -and -not $config) {
    Write-Host "Usage: $scriptName <installer.msix installer.appinstaller ...> [-o <output folder>] [-c <certificate.cer>] [-t <title>] [-d <description>] [-i <icon.ico>] [-v <version>]" -ForegroundColor Yellow
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
    Write-Host "  $scriptName installer.msix installer.appinstaller -o output -c certificate.cer -t 'Installer Title' -d 'Installer Description' -i icon.ico -v '1.0.0'"
    exit
}

if (-not (Get-Module -ListAvailable -Name ps2exe)) {
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

$embeddedInstallScript = @'
$certPath = Join-Path $env:TEMP "msix-no-cert.certificate.cer"
$installerPath = Get-ChildItem -Path $env:TEMP -Filter msix-no-cert.installer.* | Select-Object -First 1 -ExpandProperty FullName

if (Test-Path $certPath) {
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath)

    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("TrustedPeople", "LocalMachine")
    $store.Open("ReadWrite")
    $store.Add($cert)
    $store.Close()
}

Start-Process -FilePath $installerPath
'@

for ($i = 0; $i -lt $configObj.input.count; $i++) {
    $installSourcePath = Join-Path $env:TEMP "msix-no-cert.setup.ps1"
    Set-Content -Path $installSourcePath -Value $embeddedInstallScript -Encoding UTF8
    
    $extension = [System.IO.Path]::GetExtension($configObj.input[$i])
    Invoke-PS2EXE `
        -InputFile $installSourcePath `
        -OutputFile (Join-Path $configObj.output "$(Split-Path $configObj.input[$i] -Leaf).exe") `
        -IconFile $configObj.icon `
        -title $configObj.title `
        -description $configObj.description `
        -version $configObj.version `
        -embedFiles @{"%TEMP%\msix-no-cert.certificate.cer" = $configObj.cert; "%TEMP%\msix-no-cert.installer$extension" = $configObj.input[$i] } `
        -NoConsole `
        -RequireAdmin `
        -verbose
}

Write-Host "$($configObj.input.count) installers created." -ForegroundColor Green
