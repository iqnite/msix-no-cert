# Self-signed MSIX package creation tool

Normally, Microsoft package installers (MSIX) require a certificate signed by an official certificate authority, which can cost up to 500$/year. For further details, see [this issue](https://github.com/microsoft/msix-packaging/issues/332).

This PowerShell script works around the issue by installing a self-signed certificate (which is free) to the user's machine and running the package installer afterwards.

## Limitations

Before using this tool, consider the following:

- The user will need to extract a ZIP archive before installing. A standalone EXE installer is being worked on.
- Some antivirus software might show security warnings when trying to run the installer. However, these can be easily clicked away by the user.

If you are okay with these, read on!

## Prerequisites

To use this tool, you will need:

- [7-Zip](https://www.7-zip.org/)
- A self-signed certificate (`.cer` file)
- An app installer file (`.msix`, `.appinstaller`, `.exe`, ...)

> [!TIP]
> The certificate and installer files are generated automatically if you are using Visual Studio with the WinUI 3 template. To get them, select "Project" > "Package and publish" > "Create application packages...".

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

- 7-Zip is installed on your system and located at `%ProgramFiles%\7-Zip\7z.exe`
- all relative paths are correct
- you have passed the `-cert`, `-output`, and installer parameters correctly
- the certificate is in `.cer` format
- the app icon has the `.ico` file extension
