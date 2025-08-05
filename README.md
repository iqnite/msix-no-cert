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
- An app installer file (`.msix` or `.appinstaller`)

> [!TIP]
> The certificate and installer files are generated automatically if you are using Visual Studio with the WinUI 3 template. To get them, select "Project" > "Package and publish" > "Create application packages...".

## Usage

> [!NOTE]
> The program supports both `.msix` and `.appinstaller` files. In this guide, only MSIX will be mentioned for simplicity, but everything that works with MSIX applies to AppInstaller as well.

### Preparing the installer

First, copy your `.msix` and `.cer` file to the `installer` folder, and rename them to `app.msix` and `app.cer`, respectively.

Next, in the `assets` folder, copy `installer_config.json.example` and rename the new file to `installer_config.json`. Replace the sample data in the JSON with your app's information.

> [!IMPORTANT]
> Include any files that are required during the installation process (such as additional installers, certificates, and dependencies) in the `installer` folder. Files that are required to create the installer, but not during the installation process (such as the installer icon) should be included in the `assets` folder instead.

### Creating the installer

Now that the initial setup is complete, run `create_installer.ps1`. It will create a ZIP archive that can be distributed to your users!

## Troubleshooting

If you cannot start `create_installer.ps1`, try running the following command instead:

```powershell
pwsh .\create_installer.ps1
```

If any errors occur during the installer creation, ensure that:

- 7-Zip is installed on your system and located at `%ProgramFiles%\7-Zip\7z.exe`
- all relative paths (such as paths to `assets`) are correct
- the `installer` folder contains `app.msix` and `app.cer`
- the app icon has the `.ico` file extension

## Technical description

```txt
+-------------------+              +----------------------+
|   installer.zip   |              | create_installer.ps1 |<-------------------[assets]
|                   |              |                      |
|   [install.exe]<--+--------------+-------{PS2EXE}-------+--------------------[install.ps1]
|   [app.cer]       |              |                      |                     V         V
|   [app.msix]      |<-------------+-------{7-Zip}--------+-----------------[app.cer]+[app.msix]
+-------------------+              +----------------------+
```

`install.ps1` is a PowerShell script that first installs `app.cer` with administrator permissions and then launches `app.msix` for the user to install. To allow users to install the app without needing to run scripts, `create_installer.ps1` first converts the installation script to an executable using the `installer_config.json`, and then puts the newly created `install.exe`, the certificate, and the MSIX package in a ZIP archive.
