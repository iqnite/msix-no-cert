# Certificate-less MSIX package creation tool

A small PowerShell utility that allows creating installers for MSIX files without an official certificate.

## Background

See [this issue](https://github.com/microsoft/msix-packaging/issues/332).

## Prerequisites

To use this tool, you will need:

- 7-ZIP
- A self-signed certificate (`.cert` file)
- An MSI(X) installer

The last 2 are generated automatically if you are using Visual Studio with the WinUI 3 template by right-clicking on the project and selecting "Package and publish..." > "Create application packages...".

## Usage

### Preparing the installer

First, copy your `.msi(x)` and `.cer` file to the `installer` folder, and rename them to `app.msix` (or `app.msi`) and `app.cer`, respectively.

> [!IMPORTANT]
> Include any files that are required during the installation process (such as additional installers, certificates, and dependencies) in the `installer` folder. Files that are required to create the installer, but not during the installation process (such as the installer icon) should be included in the `assets` folder instead.

Next, in the `assets` folder, copy `installer_config.json.example` and rename the new file to `installer_config.json`. Replace the sample data in the JSON with your app's information.

> [!IMPORTANT]
> The app icon must be an `.ico` file! Also make sure that all relative paths (such as paths to `assets`) are correct.

### Creating the installer

Now that the initial setup is complete, run `create_installer.ps1`. It will create a `zip` file that can be distributed to your users!
