$scriptPath = $PSScriptRoot

$certPath = Get-ChildItem -Path $scriptPath -Filter *.cer | Select-Object -First 1 -ExpandProperty FullName
$installerPath = Get-ChildItem -Path $scriptPath -Filter installer.* | Select-Object -First 1 -ExpandProperty FullName

$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath)

$store = New-Object System.Security.Cryptography.X509Certificates.X509Store("TrustedPeople", "LocalMachine")
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()

Start-Process -FilePath $installerPath
