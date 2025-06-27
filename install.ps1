$certPath = "app.cer"
$msixPath = "app.msix"
$appinstallerPath = "app.appinstaller"

$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath)

$store = New-Object System.Security.Cryptography.X509Certificates.X509Store("TrustedPeople", "LocalMachine")
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()

if (Test-Path $appinstallerPath) {
    Start-Process -FilePath $appinstallerPath
}
elseif (Test-Path $msixPath) {
    Start-Process -FilePath $msixPath
}
