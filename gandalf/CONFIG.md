# Evidence Acquisition Configuration

Potential additional configuration requirements<br><br>
<!-- TABLE OF CONTENTS -->
# Table of Contents

- [Evidence Acquisition Configuration](#evidence-acquisition-configuration)
- [Table of Contents](#table-of-contents)
  - [Windows](#windows)
    - [Enabling PowerShell remoting](#enabling-powershell-remoting)
    - [hosts.list](#hostslist)
  - [Linux/macOS](#linuxmacos)
    - [Enabling SSH](#enabling-ssh)
    - [hosts.list](#hostslist-1)
  - [Cross-Platform Acquisition (XPC)](#cross-platform-acquisition-xpc)
    - [Windows -\> Linux/macOS](#windows---linuxmacos)
      - [Installing Python3](#installing-python3)
    - [Linux/macOS -\> Windows](#linuxmacos---windows)

## Windows

### Enabling PowerShell remoting
*To enable PowerShell remoting, ensure that **TCP ports 5985 and 5986** are open on the necessary firewalls for WSMAN protocol. You will, of course, also need to be using an account which is a member of the **local Administrator group**. Once done, run the following commands.*<br><br>
Acquisition Host (Windows)<br>
`Set-Item -Path WSMan:\localhost\Client\TrustedHosts <HOSTNAME(s)> -Force`<br>
`Enable-PSRemoting -Force`<br><br>
Target Host (Windows)<br>
`Enable-PSRemoting -Force`<br>

**Remember to revert any changes made, if necessary, after the artefacts have been acquired.**<br>

### hosts.list
`sudo git clone https://github.com/ezaspy/gandalf.git`
- Edit [...\gandalf\gandalf\hosts.list](https://github.com/ezaspy/gandalf/blob/main/gandalf/hosts.list)
- Move [\gandalf](https://github.com/ezaspy/gandalf/tree/main/gandalf) to **acquisition** host<br><br>
<br><br>

## Linux/macOS

### Enabling SSH
*To enable SSH for remote artefact acquisition, ensure that **port 22** is open on the target-host, as well as having the necessary firewall rules enabled. You will, of course, also need to be using a **root-level account**. The following configurations are required on the **Target Host** only.*<br>

`sudo [apt/yum/zypper/dnf/pacman] install openssh-server -y`<br>
`sudo ufw enable`<br><br>
Acquisition from Specific Host
- `sudo ufw allow from 10.10.10.2 to any port ssh`<br>
Acquisition from Specific Subnet
- `sudo ufw allow from 10.10.10.0/24 to any port ssh`<br>
Acquisition from Any Host
- `sudo ufw allow ssh`<br><br>

**Remember to revert any changes made, if necessary, after the artefacts have been acquired.**<br>

### hosts.list

`sudo git clone https://github.com/ezaspy/gandalf.git`
- Edit [.../gandalf/gandalf/hosts.list](https://github.com/ezaspy/gandalf/blob/main/gandalf/hosts.list)
- Move [/gandalf](https://github.com/ezaspy/gandalf/tree/main/gandalf) to **acquisition** host
- sudo pip install -r requirements.txt<br><br>
<br><br>

## Cross-Platform Acquisition (XPC)
*The following configurations are required on the **Acquisition Host** only.*<br>

### Windows -> Linux/macOS

#### Installing Python3
Install Python3 on Windows, from the following [instructions](https://docs.python.org/3/using/windows.html).
[Enable SSH](#enabling-ssh) as required.<br><br>

### Linux/macOS -> Windows

*Other Linux distribution instructions can be found under [Install PowerShell on Linux](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.3)*<br>

`/tmp/gandalf/gandalf/tools/config/./config_gandalf_for_[Alpine/Debian/RHEL7/RHEL8/Ubuntu/macOS].sh`

Configure [PowerShell Remoting](#enabling-powershell-remoting) as required.<br><br>
