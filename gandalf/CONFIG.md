# Additional Configuration

Potential additional configuration requirements<br><br>
<!-- TABLE OF CONTENTS -->
# Table of Contents

* [PowerShell Remoting](#Enabling-PowerShell-remoting)
    * [Source Host](#Source-Host)
    * [Target Host](#Target-Host)
    * [hosts.list](#hosts.list)
        * [Windows](#Windows)
        * [Linux/macOS](#Linux-macOS)
<br><br>

## Enabling PowerShell remoting
To enable PowerShell remoting, ensure that *TCP ports 5985 and 5986* are open on the necessary firewalls for WSMAN protocol. You will, of course, also need to be using an account which is a member of the *local Administrator group*. Once done, run the following command on the respective machines:
### Source Host
`Set-Item -Path WSMan:\localhost\Client\TrustedHosts <HOSTNAME(s)> -Force`<br>
`Enable-PSRemoting -Force`<br>
### Target Host
`Enable-PSRemoting -Force`<br><br>
### hosts.list

#### Windows
`sudo git clone https://github.com/ezaspy/gandalf.git`
- Edit **...\gandalf\gandalf\shire\hosts.list**
- Move **...\gandalf** to acquisition host<br><br>

#### Linux/macOS

`sudo git clone https://github.com/ezaspy/gandalf.git`
- Edit **.../gandalf/gandalf/shire/hosts.list**
- Move **.../gandalf** to acquisition host<br><br>

