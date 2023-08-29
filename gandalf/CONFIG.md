# Additional Configuration

Potential additional configuration requirements<br><br>
<!-- TABLE OF CONTENTS -->
# Table of Contents

* [Windows](#windows)
  * [PowerShell Remoting](#enabling-powershell-remoting)
    * [Source Host](#source-host)
    * [Target Host](#target-host)
  * [hosts.list](#hosts.list)
* [Linux/macOS](#linux-macos)
  * [Enabling SSH](#enabling-ssh)
  * [hosts.list](#hosts.list)
<br><br>

## Windows

### Enabling PowerShell remoting
To enable PowerShell remoting, ensure that *TCP ports 5985 and 5986* are open on the necessary firewalls for WSMAN protocol. You will, of course, also need to be using an account which is a member of the *local Administrator group*. Once done, run the following command on the respective machines:
#### Source Host
`Set-Item -Path WSMan:\localhost\Client\TrustedHosts <HOSTNAME(s)> -Force`<br>
`Enable-PSRemoting -Force`<br>
#### Target Host
`Enable-PSRemoting -Force`<br>

**Remember to revert any changes made, if necessary, after the artefacts have been acquired.**<br>

### hosts.list
`sudo git clone https://github.com/ezaspy/gandalf.git`
- Edit [...\gandalf\gandalf\hosts.list](https://github.com/ezaspy/gandalf/blob/main/gandalf/hosts.list)
- Move [\gandalf](https://github.com/ezaspy/gandalf/tree/main/gandalf) to **acquisition** host<br><br>
<br><br>

## Linux/macOS

### Enabling SSH
To enable SSH for remote artefact acquisition, ensure that port 22 is open on the target-host, as well as having the necessary firewall rules enabled. You will, of course, also need to be using a *root*-level account (to acquire the necessary artefacts):
#### Target Host
`sudo [apt/yum/zypper/dnf/pacman] install openssh-server -y`<br>
`sudo ufw enable`<br>
##### Acquisition from Specific Host
- `sudo ufw allow from 10.10.10.2 to any port ssh`<br>
##### Acquisition from Specific Subnet
- `sudo ufw allow from 10.10.10.0/24 to any port ssh`<br>
##### Acquisition from Any Host
- `sudo ufw allow ssh`<br><br>

**Remember to revert any changes made, if necessary, after the artefacts have been acquired.**<br>

### hosts.list

`sudo git clone https://github.com/ezaspy/gandalf.git`
- Edit [.../gandalf/gandalf/hosts.list](https://github.com/ezaspy/gandalf/blob/main/gandalf/hosts.list)
- Move [/gandalf](https://github.com/ezaspy/gandalf/tree/main/gandalf) to **acquisition** host
- sudo pip install -r requirements.txt<br><br>
