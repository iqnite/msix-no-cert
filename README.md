# Certificate-less MSIX package creation tool

A small PowerShell utility that allows creating installers for MSIX files without an official certificate.

## Background

See [this issue](https://github.com/microsoft/msix-packaging/issues/332).

## Prerequisites

To use this tool, you will need:

- [7-Zip](https://www.7-zip.org/)
- A self-signed certificate (`.cer` file)
- An MSIX installer

The last 2 are generated automatically if you are using Visual Studio with the WinUI 3 template by right-clicking on the project and selecting "Package and publish..." > "Create application packages...".

## Usage

### Preparing the installer

First, copy your `.msix` and `.cer` file to the `installer` folder, and rename them to `app.msix` and `app.cer`, respectively.

> [!IMPORTANT]
> Include any files that are required during the installation process (such as additional installers, certificates, and dependencies) in the `installer` folder. Files that are required to create the installer, but not during the installation process (such as the installer icon) should be included in the `assets` folder instead.

Next, in the `assets` folder, copy `installer_config.json.example` and rename the new file to `installer_config.json`. Replace the sample data in the JSON with your app's information.

### Creating the installer

Now that the initial setup is complete, run `create_installer.ps1`. It will create a ZIP archive that can be distributed to your users!

## Troubleshooting

If you cannot start `create_installer.ps1`, try running the following command instead:

```powershell
pwsh .\create_installer.ps1
```

If any error occur during the installer creation, ensure that:

- 7-Zip is installed on your system and located at `%ProgramFiles%\7-Zip\7z.exe`
- all relative paths (such as paths to `assets`) are correct
- the `installer` folder contains `app.msix` and `app.cer`
- the app icon is has the `.ico` file extension
