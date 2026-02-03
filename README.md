# Self-signed MSIX package creation tool

Normally, Microsoft package installers (MSIX) require a certificate signed by an official certificate authority, which can cost up to 500$/year. For further details, see [this issue](https://github.com/microsoft/msix-packaging/issues/332).

This PowerShell script works around the issue by installing a self-signed certificate (which is free) to the user's machine and running the package installer afterwards.

## Before you begin

The Microsoft Store allows individuals to publish and certify apps for free. If you are eligible, consider [publishing your app through the Microsoft Store](https://storedeveloper.microsoft.com/) instead of using this tool, as it provides a more secure and trusted installation experience.

If you decide to use this tool, be aware that some antivirus software, such as Windows SmartScreen, might show security warnings when trying to run the installer. While the user can usually bypass these warnings by choosing to run the installer anyway, it is important to inform your users about this possibility beforehand to avoid confusion or mistrust. Also, it will require administrator privileges to install the certificate, which might not be suitable for all users.

## Credits

This tool utilizes PS2EXE by Markus Scholtes to convert PowerShell scripts into executable files. For more information, visit the [PS2EXE GitHub repository](https://github.com/MScholtes/PS2EXE).

## Usage

To create an installer, run a command in the following format:

```powershell
.\msix-no-cert.exe <installers> [-o <output folder>] [-c <certificate.cer>] [-t <title>] [-d <description>] [-i <icon.ico>] [-v <version>]
```

Options:

- `-o`, `-output` Output path for the installer archives.
- `-c`, `-cert` Path to the certificate file.
- `-t`, `-title` Title of the installer.
- `-d`, `-description` Description of the installer.
- `-i`, `-icon` Path to the icon file for the installer.
- `-v`, `-version` Version number for the installer.
- `-h`, `-help` Display this help message.
- `-config` Path to a JSON configuration file, to be used instead of the above options.

Example:

```powershell
.\msix-no-cert.exe installer.msix installer.appinstaller -o output -c certificate.cer -t 'My Cool App Installer' -d 'Installs My Cool App, an app that does something.' -i my-app-icon.ico -v '1.0.0'
```

### JSON Options

You can create a JSON configuration file with the command options, so you don't have to manually enter them every time.

```json
{
  "input": ["installer.msix", "installer.appinstaller"],
  "output": "output",
  "cert": "certificate.cer",
  "title": "My Cool App Installer",
  "description": "Installs My Cool App, an app that does something.",
  "icon": "my-app-icon.ico",
  "version": "1.0.0"
}
```

You can then use the following command to create the installer, based on your JSON file:

```powershell
.\msix-no-cert.exe -config <path-to-json-file.json>
```

## Troubleshooting

If any errors occur during the installer creation, ensure that:

- all relative paths are correct
- you have passed the `-cert`, `-output`, and installer parameters correctly
- the certificate is in `.cer` format
- the app icon has the `.ico` file extension
