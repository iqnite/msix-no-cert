$certPath = "app.cer"
$msixPath = "app.msix"

$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certPath)

$store = New-Object System.Security.Cryptography.X509Certificates.X509Store("TrustedPeople", "LocalMachine")
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()

Start-Process -FilePath $msixPath
