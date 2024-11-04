# PowerShell Reporting Best Practice

## Table of Contents

- [PowerShell Reporting Best Practice](#powershell-reporting-best-practice)
  - [Table of Contents](#table-of-contents)
  - [Remote Acquisition](#remote-acquisition)
    - [Just Enough Administration (JEA)](#just-enough-administration-jea)
    - [Jumphost](#jumphost)
    - [Endpoint-to-Endpoint](#endpoint-to-endpoint)
  - [Local Acquisition](#local-acquisition)

<br>

## Remote Acquisition
There are multiple methods of remote acquisition using PowerShell. The three supported methods are listed below in order of recommendation. All methods may require additional confoguration changes at the necessary firewalls or switches to facilitate PowerShell remoting.
<br><br>

### Just Enough Administration (JEA)
Just Enough Administration (JEA) is a security technology that enables delegated administration for anything managed by PowerShell. With JEA, you can:
- Reduce the number of administrators on your machines using virtual accounts or group-managed service accounts to perform privileged actions on behalf of regular users.
- Limit what users can do by specifying which cmdlets, functions, and external commands they can run.
- Better understand what your users are doing with transcripts and logs that show you exactly which commands a user executed during their session.
<br><br>

Microsoft provide the most relevant and up-to-date documentation on [Just Enough Administration](https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/jea/overview?view=powershell-7.2)
<br><br>

### Jumphost
As stated above, it is highly recommended to configure a system responsible for orchestrating JEA but if this is not possible, it is recommanded to stand up a Windows jumphost to facilitate PowerShell remoting. Of if you are collecting artefacts from a \*nix, standing up a Linux jumphost to facilitate Python remoting.
<br><br>

### Endpoint-to-Endpoint
Although not recommended, in some environments time is of the essence and it may not be possible to deploy a intermediary host (JEA or jumphost) in time for artefact acqisition. In such cases, you can connect to the host directly (with the appropriate credentials) to acquire the artefacts.
<br><br>

## Local Acquisition
If configuring JEA or a jumphost is not feasible, the next best option would be to acquire the artefacts on the machine itself; locally. This doesn't require any addition tooling or requirements and can be performed directly on the host, via a network share or via an external drive, such as a USB - different command line switches will be required though. Usage examples can be found in the [README.md](https://github.com/ezaspy/gandalf/blob/main/gandalf/README.md#Usage).<br><br><br>
