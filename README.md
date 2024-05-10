<p align="center">
  <a href="https://github.com/ezaspy/gandalf"><img src="gandalf/images/logo_trans_big.png" alt="Logo" width="400" height="400"></a>
  <p align="center">
    Forensics artefact acquisition scripts to be used in conjunction with elrond.
    <br><br>
    <a href="https://mit-license.org"><img src="https://img.shields.io/github/license/ezaspy/gandalf" alt="License: MIT"></a>
    <a href="https://github.com/ezaspy/gandalf/issues"><img src="https://img.shields.io/github/issues/ezaspy/gandalf" alt="Issues"></a>
    <a href="https://github.com/ezaspy/gandalf/network/members"><img src="https://img.shields.io/github/forks/ezaspy/gandalf" alt="Forks"></a>
    <a href="https://github.com/ezaspy/gandalf/stargazers"><img src="https://img.shields.io/github/stars/ezaspy/gandalf" alt="Stars"></a>
    <a><img src="https://img.shields.io/badge/subject-DFIR-red" alt="Subject"></a>
    <a><img src="https://img.shields.io/github/last-commit/ezaspy/gandalf" alt="Last Commit"></a>
    <a href="https://github.com/psf/black"><img alt="Code style: black" src="https://img.shields.io/badge/code%20style-black-000000.svg"></a>
    <br><br>
  </p>
</p>

## Table of Contents

- [About the Project](#about-the-project)
  - [Related Projects](#related-projects)
- [Configuration](#configuration)
  - [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Artefacts](#artefacts)
  - [Windows](#windows)
  - [Linux](#linux)
  - [macOS](#macos)
- [Acknowledgements](#acknowledgements)

<br><br>

## About The Project

gandalf has been created to help fellow digitial forensicators with the live collection of forensic artefacts from a Windows, Linux and masOS hosts. Depending on the host OS, either gandalf.ps1 or gandalf.py will be required; to ensure compatibility for Windows and \*nix hosts respectively. gandalf is designed to be faster, but additional features *({-Memory, -CollectFiles}/{-M, -A, -F})* may result is longer acquisitions times, subject to network speeds and latency of course.
<br>

### Related Projects

gandalf is responsible for the acquisition-side of digital forensics, but what about analysis? [elrond](https://github.com/ezaspy/elrond), converts all of the artefacts to either JSON or CSV and can then stand up an on-the-fly [Splunk](https://www.splunk.com/) or [elastic](https://www.elastic.co/) instance whilst mapping the evidence within those artefacts to the [MITRE ATT&CK® Framework](https://attack.mitre.org/) using [ATT&CK Navigator](https://mitre-attack.github.io/attack-navigator/), if desired.
<br><br><br>

## Configuration

To collect privileged disk arterfacts, namely the `$MFT`, you will need to download the [`disk_tools.zip.enc`](https://drive.google.com/file/d/1LwmTMcJm8ggIvQnbSLT5-0CRG8NBBBdR/view?usp=share_link) archive (password is `infected`) and place the enclosed archive (`disk_tools.zip`) into `gandalf\gandalf\tools\` before deploying and invoking gandalf for artefact aquisition.<br>

### Prerequisites

You must have necessary admin rights to obtain the forensic artefacts from hosts within your environment. This is true for both Local and Remote acquisitions. On Windows Server 2012+ remoting is enabled by default. You only need to confirm that your firewall rules allow inbound access. However, no Windows client OS has PowerShell remoting enabled by default.<br>
Additional installations may be required on Linux/macOS hosts for the target hosts to allow inbound SSH connections.<br>
Please review the [SUPPORT.md](https://github.com/ezaspy/gandalf/blob/main/gandalf/SUPPORT.md) file for instructions on how to leverage and deploy gandalf.
<br><br><br>

## Usage

Please read the [CONFIG.md](https://github.com/ezaspy/gandalf/blob/main/gandalf/CONFIG.md) file for instructions on how to enable PowerShell remoting (for Windows Targets) and SSH remoting (for Linux/macOS hosts).<br><br>

### Windows

- **Open 'Windows PowerShell' (not PowerShell Core) with Local Administrator privileges**<br>
  - Keyboard shortcut: </kbd>WIN</kbd> + </kbd>X</kbd> + </kbd>A</kbd>

`.\Invoke-Gandalf.ps1 [-EncryptionObject <Key/Password/None>] [-Acquisition <Local/Remote>] [-OutputDirectory <C:\Path\To\Output\Location>] [-Memory] [-ShowProgress] [-CollectFiles]`<br><br>

### Linux/macOS
- **Open 'Terminal' as root**<br>

`sudo python3 gandalf.py [-h] <Key/Password/None> <Local/Remote> [-O <output_directory>] [-M] [-A] [-C]`<br><br>

### Cross-Platform Acquisition (XPC)
#### Windows -> Linux/macOS
- **Open 'Windows PowerShell' (not PowerShell Core) with Local Administrator privileges**<br>

`python3 gandalf.py [-h] <Key/Password/None> <Local/Remote> [-O <output_directory>] [-M] [-A] [-C]`<br><br>

#### Linux/macOS -> Windows
- **Open 'Terminal' as root**<br>

`pwsh`<br>
`./Invoke-Gandalf.ps1 [-EncryptionObject <Key/Password/None>] [-Acquisition <Local/Remote>] [-OutputDirectory <\Path\To\Output\Location>] [-Memory] [-ShowProgress] [-CollectFiles]`
<br><br><br>

## Artefacts

Below is a list of all the artefacts collected and processed from the respective operating systems.

### Windows

_

### Linux

_

### macOS

_

<br><br><br>

## Acknowledgements

- [Jason Fossen](https://blueteampowershell.com/)<br>
- [SANS](https://www.sans.org)<br>
- [7Zip4PowerShell](https://www.powershellgallery.com/packages/7Zip4Powershell/2.2.0)<br>
- [TheSleuthKit](https://sleuthkit.org/)<br>
- [DumpIt](https://github.com/Crypt2Shell/Comae-Toolkit)<br>
- [RawCopy](https://github.com/jschicht/RawCopy)<br><br>
- Documentation
  - [Best-README-Template](https://github.com/othneildrew/Best-README-Template)
  - [hatchful](https://hatchful.shopify.com)
  - [Image Shields](https://shields.io)
- Theme &amp; Artwork
  - [J.R.R. Tolkien](https://en.wikipedia.org/wiki/J._R._R._Tolkien)
  - [Peter Jackson](https://twitter.com/ReaPeterJackson)
  - [ASCII Text Generator](https://textkool.com/en/ascii-art-generator?hl=default&vl=default&font=Red%20Phoenix&text=Your%20text%20here%20)
  - [ASCII Art Generator](https://www.ascii-art-generator.org)
  - [ASCII World](http://www.asciiworld.com/-Lord-of-the-Rings-.html)
- Other
  - [Powershell on macOS WSMan issue](https://www.oasys.net/fragments/powershell-on-macos-wsman/)

[gandalf-screenshot]: images/screenshot.png
