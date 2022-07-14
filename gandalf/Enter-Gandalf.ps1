<#
 .Synopsis
 Collects forensic artefacts on Windows hosts; compatible with elrond
 Version: 0.1
 Author : ezaspy
 License: MIT
 .Description
 Collects digital forensic artefacts from Windows hosts. Output is compatible
  with elrond ()
 .Parameter EncryptionObject
 Method of encryption used for archive file
 .Parameter Acquisition
 Method of acquisition - either Remote or Local
 .Parameter OutputDirectory
 Destination directory of where the collected will be stored
 .Example
 The following example invokes all of the parameters with the default arguments;
  -Acquisition Local -EncryptionObject Key -OutputDirectory .\
  PS C:\> .\Enter-Gandalf.ps1
 .Example
 The following example invokes all of the parameters with the default arguments;
  explicitly stated:
  PS C:\> .\Enter-Gandalf.ps1 -Acquisition Local -EncryptionObject Key -OutputDirectory C:\TEMP\Gandalf
 .Example
 The following example invokes all of the parameters with non-default arguments;
  deployment against a remote host, specified by IP or Hostname, a (less secure) 
  password-protected package, and outputted to the root directory on the D: drive.
  PS C:\> .\Gandalf.ps1 -Acquisition <REMOTE_HOST> -EncryptionObject Password -OutputDirectory D:
#>
Param(
  [Parameter(Mandatory=$True)][string]$EncryptionObject,
  [string]$Acquisition,
  [string]$OutputDirectory,
  [switch]$Memory,
  [switch]$ShowProgress
  #[switch]$Quiet
)

<#
    Define Functions
#>
function Format-Art
{
    $quotes = @("     Not come the days of the King.`n     May they be blessed.`n`n", "     If my old gaffer could see me now.`n`n", "     I'll have no pointy-ear outscoring me!`n`n", "     I think there is more to this hobbit, than meets the eye.`n`n", "     You are full of surprises Master Baggins.`n`n", "     One ring to rule them all, one ring to find them.`n     One ring to bring them all, and in the darkness bind them.`n`n", "     The world is changed.`n     I feel it in the water.`n     I feel it in the earth.`n     I smell it in the air.`n`n", "     Who knows? Have patience. Go where you must go, and hope!`n`n", "     All we have to decide is what to do with the time that is given us.`n`n", "     Deeds will not be less valiant because they are unpraised.`n`n", "     It is not the strength of the body, but the strength of the spirit.`n`n", "     But in the end it's only a passing thing, this shadow; even darkness must pass.`n`n", "     It's the job that's never started as takes longest to finish.`n`n", "     Coward? Not every man's brave enough to wear a corset!`n`n", "     Bilbo was right. You cannot see what you have become.`n`n", "     He is known in the wild as Strider.`n     His true name, you must discover for yourself.`n`n", "     Legolas said you fought well today. He's grown very fond of you.`n`n", "     You will take NOTHING from me, dwarf.`n     I laid low your warriors of old.`n     I instilled terror in the hearts of men.`n     I AM KING UNDER THE MOUNTAIN!`n`n", "     You've changed, Bilbo Baggins.`n     You're not the same Hobbit as the one who left the Shire...`n`n", "     The world is not in your books and maps. It's out there.`n`n", "     That is private, keep your sticky paws off! It's not ready yet!`n`n", "     I wish you all the luck in the world. I really do.`n`n", "     No. No. You can't turn back now. You're part of the company.`n     You're one of us.`n`n", "     True courage is about knowing not when to take a life, but when to spare one.`n`n", "     The treacherous are ever distrustful.`n`n", "     Let him not vow to walk in the dark, who has not seen the nightfall.`n`n", "     He that breaks a thing to find out what it is has left the path of wisdom.`n`n", "     I was there, Gandalf.`n     I was there three thousand years ago, when Isildur took the ring.`n     I was there the day the strength of Men failed.`n`n", "     I don't know half of you half as well as I should like,`n     and I like less than half of you half as well as you deserve.`n`n", "     Certainty of death. Small chance of success.`n     What are we waiting for?`n`n", "     Do not spoil the wonder with haste!`n`n", "     It came to me, my own, my love... my... preciousssss.`n`n", "     One does not simply walk into Mordor...`n`n", "     Nine companions. So be it. You shall be the fellowship of the ring.`n`n", "     You have my sword. You have my bow; And my axe!`n`n", "     Build me an army, worthy of Mordor!`n`n", "     Nobody tosses a Dwarf!`n`n", "     If in doubt, Meriadoc, always follow your nose.`n`n", "     This is beyond my skill to heal; he needs Elven medicine.`n`n", "     No, thank you! We don't want any more visitors, well-wishers or distant relations!`n`n", "     Mordor! I hope the others find a safer road.`n`n", "     YOU SHALL NOT PASS!`n`n", "     You cannot hide, I see you!`n     There is no life, after me.`n     Only!.. Death!`n`n", "     A wizard is never late, Frodo Baggins.`n     Nor is he early.`n     He arrives precisely when he means to.`n`n", "     Is it secret?! Is it safe?!`n`n", "     Even the smallest person can change the course of the future.`n`n", "     We must move on, we cannot linger.`n`n", "     I wish the ring had never come to me. I wish none of this had happened.`n`n", "     Moonlight drowns out all but the brightest stars.`n`n", "     A hunted man sometimes wearies of distrust and longs for friendship.`n`n", "     The world is indeed full of peril and in it there are many dark places.`n`n", "     Someone else always has to carry on the story.`n`n", "     Your time will come. You will face the same Evil, and you will defeat it.`n`n", "     It is useless to meet revenge with revenge; it will heal nothing.`n`n", "     Despair is only for those who see the end beyond all doubt. We do not.`n`n", "     Anyways, you need people of intelligence on this sort of... mission... quest... thing.`n`n", "     Oh, it's quite simple. If you are a friend, you speak the password, and the doors will open.`n`n", "     The wise speak only of what they know.`n`n", "     Not all those who wander are lost.`n`n", "     It's the deep breath before the plunge.`n`n")
    Write-Host "
    `n`n`n`n`n
         ____                      .___        .__    _____  
        / ___\ _____     ____    __| _/_____   |  | _/ ____\ 
       / /_/  >\__  \   /    \  / __ | \__  \  |  | \   __\  
       \___  /  / __ \_|   |  \/ /_/ |  / __ \_|  |__|  |    
      /_____/  (____  /|___|  /\____ | (____  /|____/|__|    
                    \/      \/      \/      \/               
    " -Foreground White
    $quote = Get-Random -InputObject $quotes
    Write-Host $quote -Foreground Gray
}

function Format-Time
{
    Param ($TimeDifference)
    $Seconds = [math]::round($TimeDifference % 60)
    $Minutes = [math]::round($TimeDifference / 60 % 60)
    $Hours = [math]::round($TimeDifference / 60 / 60)
    if ($Hours -gt 1 -Or $Hours -eq 1) {
        if ($Hours -gt 1 -And $Minutes -gt 1 -And $Seconds -gt 1) {
            $ElapsedTime = "$Hours hours, $Minutes minutes and $Seconds seconds."
        }
        elseif ($Hours -gt 1 -And $Minutes -gt 1 -And $Seconds -eq 1) {
            $ElapsedTime = "$Hours hours, $Minutes minutes and $Seconds second."
        }
        elseif ($Hours -gt 1 -And $Minutes -eq 1 -And $Seconds -gt 1) {
            $ElapsedTime = "$Hours hours, $Minutes minute and $Seconds seconds."
        }
        elseif ($Hours -eq 1 -And $Minutes -gt 1 -And $Seconds -gt 1) {
            $ElapsedTime = "$Hours hour, $Minutes minutes and $Seconds seconds."
        }
        elseif ($Hours -gt 1 -And $Minutes -eq 1 -And $Seconds -eq 1) {
            $ElapsedTime = "$Hours hours, $Minutes minute and $Seconds second."
        }
        elseif ($Hours -eq 1 -And $Minutes -gt 1 -And $Seconds -eq 1) {
            $ElapsedTime = "$Hours hour, $Minutes minutes and $Seconds second."
        }
        elseif ($Hours -eq 1 -And $Minutes -eq 1 -And $Seconds -gt 1) {
            $ElapsedTime = "$Hours hour, $Minutes minute and $Seconds seconds."
        }
        elseif ($Hours -gt 1 -And $Minutes -gt 1 -And $Seconds -eq 0) {
            $ElapsedTime = "$Hours hours and $Minutes minutes."
        }
        elseif ($Hours -gt 1 -And $Minutes -eq 0 -And $Seconds -gt 0) {
            $ElapsedTime = "$Hours hours and $Seconds seconds."
        }
        elseif ($Hours -eq 1 -And $Minutes -gt 1 -And $Seconds -eq 0) {
            $ElapsedTime = "$Hours hour and $Minutes minutes."
        }
        elseif ($Hours -eq 1 -And $Minutes -eq 0 -And $Seconds -gt 0) {
            $ElapsedTime = "$Hours hour and $Seconds second."
        }
        elseif ($Hours -gt 1 -And $Minutes -eq 0 -And $Seconds -eq 0) {
            $ElapsedTime = "$Hours hours."
        }
        else {
            $ElapsedTime = "$Hours hour."
        }
    }
    elseif ($Minutes -gt 1 -Or $Minutes -eq 1) {
        if ($Minutes -gt 1 -And $Seconds -gt 1) {
            $ElapsedTime = "$Minutes minutes and $Seconds seconds."
        }
        elseif ($Minutes -eq 1 -And $Seconds -gt 1) {
            $ElapsedTime = "$Minutes minute and $Seconds seconds."
        }
        elseif ($Minutes -gt 1 -And $Seconds -eq 1) {
            $ElapsedTime = "$Minutes minute and $Seconds seconds."
        }
        elseif ($Minutes -eq 1 -And $Seconds -eq 1) {
            $ElapsedTime = "$Minutes minute and $Seconds second."
        }
        else {
            $ElapsedTime = "$Minutes minutes."
        }
    }
    else {
        if ($Seconds -gt 1) {
            $ElapsedTime = "$Seconds seconds."
        }
        else {
            $ElapsedTime = "$Seconds second."
        }
    }
    return $ElapsedTime
}

function Get-Modules
{
    Param ($EncryptionObject)
    if (Get-Module -ListAvailable -Name 7Zip4PowerShell) {
        Write-Host "     Great! PowerShell module '7Zip4PowerShellModule' is already installed"
    } 
    else {
        Write-Host "    Attempting to install additional modules..."
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -WarningVariable NuGetSTDOUT -WarningAction SilentlyContinue -ErrorVariable SilentlyContinue > $null 2>&1
        $NuGetSTDOUT = $($NuGetSTDOUT -join " ")
        if ($NuGetSTDOUT | Select-String -Pattern "Unable to download from URI") {
            Write-Host "`n     Unable to download required modules. If you are unable to connect to the`n      Internet, you will need to use the switch -EncryptionObject with 'None'`n      Please try again.`n`n"
            Exit
        }
        else {
            if ($EncryptionObject -eq "Password") {
                if (Get-Module -ListAvailable -Name PoShKeePass) {
                    Write-Host "     Great! PowerShell module 'PoShKeePass' is already installed"
                }
                else {
                    Install-Module -Name PoShKeePass -Force
                }
            }
            Install-Module -Name 7Zip4PowerShell -Force
            Write-Host "     Additional modules installed successfully"
        }
    }
}

function New-Directories
{
    Param ($OutputDirectory, $Hostname)
    $DriveLetter = $env:SystemDrive
    if (Test-Path -LiteralPath $OutputDirectory\$Hostname) {
        Remove-Item -Path $OutputDirectory\$Hostname -Recurse > $null
    }
    New-Item -Path $OutputDirectory\$Hostname -ItemType Directory > $null
    New-Item -Path $OutputDirectory\$Hostname\artefacts\artefacts -ItemType Directory > $null
    New-Item -Path $OutputDirectory\$Hostname\artefacts\artefacts\raw -ItemType Directory > $null
    New-Item -Path $OutputDirectory\$Hostname\artefacts\artefacts\raw\wmi -ItemType Directory > $null
    New-Item -Path $OutputDirectory\$Hostname\artefacts\artefacts\raw\memory -ItemType Directory > $null
    New-Item -Path $OutputDirectory\$Hostname\artefacts\artefacts\raw\registry -ItemType Directory > $null
    New-Item -Path $OutputDirectory\$Hostname\artefacts\artefacts\raw\evt -ItemType Directory > $null
    New-Item -Path $OutputDirectory\$Hostname\artefacts\artefacts\raw\prefetch -ItemType Directory > $null
    New-Item -Path $OutputDirectory\$Hostname\artefacts\artefacts\raw\jumplists -ItemType Directory > $null
    New-Item -Path $OutputDirectory\$Hostname\artefacts\artefacts\raw\browsers -ItemType Directory > $null
    New-Item -Path $OutputDirectory\$Hostname\artefacts\artefacts\raw\browsers\edge -ItemType Directory > $null
    New-Item -Path $OutputDirectory\$Hostname\artefacts\artefacts\raw\browsers\chrome -ItemType Directory > $null
    New-Item -Path $OutputDirectory\$Hostname\artefacts\artefacts\raw\browsers\firefox -ItemType Directory > $null
    return $DriveLetter
}

function Set-Defaults
{
    Param ($EncryptionObject, $Acquisition, $OutputDirectory)
    if ($Acquisition -eq $null -Or $Acquisition -eq "") {
        $Acquisition = "Local"
    }
    else {
        $Acquisition = "Remote"
    }
    if ($EncryptionObject -eq "Key" -Or $EncryptionObject -eq "Password") {
        $ConfirmEncryption = Read-Host "     You have chosen to use encrpytion when archiving the artefacts. Although this is highly recommended, you will need an Internet connection on each endpoint, to download the additional modules.`n      Do you wish to proceed? Y/n [Y] "
        if ($ConfirmEncryption -eq "n") {
            Write-Host "      Please try again with the " -NoNewLine; Write-Host "-EncryptionObject" -NoNewLine -Foreground Magenta; Write-Host " parameter set to 'None'`n`n"
            Exit
        }
        Write-Host `r
    }
    elseif ($EncryptionObject -eq "None") {
        $ConfirmNoEncryption = Read-Host "     You have chosen to use no encrpytion when archiving the artefacts. This is not recommended.`n      Are you sure you want to proceed? y/N [N] "
        if ($ConfirmNoEncryption -ne "y") {
            Write-Host "      Please try again with the " -NoNewLine; Write-Host "-EncryptionObject" -NoNewLine -Foreground Magenta; Write-Host " parameter set to 'Key' or 'Password'`n`n"
            Exit
        }
    }
    else {
        Write-Host "    '$EncryptionObject' is not a valid option for the -EncryptionObject parameter. You can choose from 'Key' (Most Secure), 'Password' or 'None' (Least Secure)`n`n"
        Exit
    }
    if ($OutputDirectory -eq $null -Or $OutputDirectory -eq "") {
        $OutputDirectory = "C:\TEMP\gandalf\gandalf"
    }
    else
    {
        if (Test-Path -LiteralPath $OutputDirectory) {
            if (-Not($OutputDirectory.Startswith(".\"))) {
                $OutputDirectory = Join-Path -Path ".\" -ChildPath $OutputDirectory
            }
            $OverwriteDestination = Read-Host "    The destination of '$OutputDirectory' already exists. Do you wish to overwrite it? Y/n [Y]"
            if ($OverwriteDestination -ne "n") {
                Remove-Item -Path $OutputDirectory -Recurse > $null
                New-Item -Path $OutputDirectory -ItemType Directory > $null
            }
            Write-Host `n
        }
        if (-not (Test-Path -LiteralPath $OutputDirectory)) {
            New-Item -Path $OutputDirectory -ItemType Directory > $null
        }
    }
    if ($Acquisition -eq "Local") {
        if (-not (Test-Path -LiteralPath $OutputDirectory)) {
            New-Item -Path $OutputDirectory -ItemType Directory -ErrorAction Stop | Out-Null
        }
    }
    return $EncryptionObject, $Acquisition, $OutputDirectory
}

function Add-LogEntry
{
    Param ($ShowProgress, $OutputDirectory, $Hostname, $Artefact, $Message)
    $DateTime = Get-Date -Format yyyy-MM-ddTHH:mm:ss.fffffffZ
    "$DateTime,$Hostname,$Artefact,collected" | Add-Content $OutputDirectory\$Hostname\log.audit
    if ($ShowProgress) {
        Write-Host "   -> $DateTime ->"$Message
    }
}

function Get-Metadata
{
    $DateTime = "{0:o}" -f (Get-Date)
    $FileHash = Get-FileHash -Algorithm SHA256 $Artefact
    "$Hostname,$FileHash`n" | Set-Content $OutputDirectory\$Hostname\log.audit
}

function Get-Platform
{
    Param ($ShowProgress, $DriveLetter, $OutputDirectory, $Hostname)
    if ((Get-ChildItem "$DriveLetter\").Name | Select-String -Pattern "MSOCache") {
        $Platform = "Windows7"
    }
    else
    {
        $Platform = "Windows10"
    }
    "$Hostname::$Platform`n" | Set-Content $OutputDirectory\$Hostname\artefacts\artefacts\raw\host.info
    Write-Host "       Identified '$Hostname' as '$Platform'" -ForegroundColor White
    $Message = "identified '$Hostname' as $Platform"
    Add-LogEntry $ShowProgress $OutputDirectory $Hostname $Platform $Message
}

function Get-Artefacts
{
    Param ($ShowProgress, $Memory, $DriveLetter, $OutputDirectory, $Hostname)
    function Get-Volatile
    {
        Param ($ShowProgress, $Memory, $OutputDirectory, $Hostname)
        function Get-Memory
        {
            Param ($ShowProgress, $OutputDirectory, $Hostname)
            $global:ProgressPreference = "SilentlyContinue"
            $Architecture = Get-ComputerInfo | Select-Object OsArchitecture
            $Architecture = Out-String -InputObject $Architecture
            $Architecture = $Architecture -Replace '[\S\s]+(\d{2})-bit[\S\s]+', '$1'
            try {
                Write-Progress "Acquiring raw memory dump from '$Hostname'..."
                if ($Architecture -eq "64") {
                    $dumpit = {.\tools\DumpIt.exe /O .\$OutputDirectory\$Hostname\artefacts\artefacts\raw\memory\$Hostname.raw /C /N /Q}
                }
                else {
                    $dumpit = {.\tools\DumpItx86.exe /O .\$OutputDirectory\$Hostname\artefacts\artefacts\raw\memory\$Hostname.raw /C /N /Q}
                }
                Invoke-Command -ScriptBlock $dumpit > $null 2>&1
                Write-Host "       Acquired raw memory dump from '$Hostname'" -ForegroundColor Green
                $Message = "acquired live memory dump (raw) from '$Hostname'"
                Add-LogEntry $ShowProgress $OutputDirectory $Hostname "$Hostname.raw" $Message
            }
            catch {
                Write-Host "    FAILURE: memory dump could not be collected." -ForegroundColor Red
            }
            $global:ProgressPreference = "Continue"
        }
        function Get-SystemInfo
        {
            Param ($ShowProgress, $OutputDirectory, $Hostname)
            try {
                Write-Progress "Acquiring system information from '$Hostname'..."
                $global:ProgressPreference = "SilentlyContinue"
                Get-ComputerInfo | Select-Object WindowsInstallationType, WindowsInstallDateFromRegistry, WindowsProductName, WindowsRegisteredOwner, WindowsSystemRoot, BiosBIOSVersion, CsDaylightInEffect, CsDNSHostName, CsDomain, CsHypervisorPresent, CsManufacturer, CsModel, CsNetworkAdapters, CsProcessors, CsRoles, CsSystemType, CsTotalPhysicalMemory, CsUserName, OsName, OsBootDevice, OsSystemDirectory, OsWindowsDirectory, OsLocale, OsLocalDateTime, OsLastBootUpTime, OsUptime, OsArchitecture, OsLanguage, OsProductType, KeyboardLayout, TimeZone, LogonServer, PowerPlatformRole | Set-Content $OutputDirectory\$Hostname\artefacts\artefacts\system.csv
                $global:ProgressPreference = "Continue"
                Write-Host "       Acquired system information from '$Hostname'" -ForegroundColor Green
                $Message = "acquired live system information from '$Hostname'"
                Add-LogEntry $ShowProgress $OutputDirectory $Hostname "system_information(live)" $Message
            }
            catch {
                Write-Host "    FAILURE: system information could not be collected; another process may be using the same resources." -ForegroundColor Red
            }
        }
        function Get-Processes
        {
            Param ($ShowProgress, $OutputDirectory, $Hostname)
            try {
                Write-Progress "Acquiring process information from '$Hostname'..."
                Get-CimInstance -ClassName Win32_Process | Select-Object ProcessId, Name, HandleCount | Export-Csv -Path $OutputDirectory\$Hostname\artefacts\artefacts\processes.csv -NoTypeInformation
                (Get-Content -Path $OutputDirectory\$Hostname\artefacts\artefacts\processes.csv) -Replace '"(\d+)"(,")([^"]+",)"(\d+)"', '$1$2$3$4' | Set-Content $OutputDirectory\$Hostname\artefacts\artefacts\processes.csv
                Write-Host "       Acquired process information from '$Hostname'" -ForegroundColor Green
                $Message = "acquired live process information from '$Hostname'"
                Add-LogEntry $ShowProgress $OutputDirectory $Hostname "running_processes(live)" $Message
            }
            catch {
                Write-Host "    FAILURE: process information could not be collected; another process may be using the same resources." -ForegroundColor Red
            }
        }
        function Get-Drivers
        {
            Param ($ShowProgress, $OutputDirectory, $Hostname)
            try {
                Write-Progress "Acquiring driver information from '$Hostname'..."
                Get-CimInstance -ClassName Win32_SystemDriver | Select-Object DisplayName, Name, State, Status, Started | Export-Csv -Path $OutputDirectory\$Hostname\artefacts\artefacts\drivers.csv -NoTypeInformation
                (Get-Content -Path $OutputDirectory\$Hostname\artefacts\artefacts\drivers.csv) -Replace ',"([^"]+)","([^"]+)","([^"]+)","([^"]+)', ',$1,$2,$3,$4' | Set-Content $OutputDirectory\$Hostname\artefacts\artefacts\drivers.csv
                Write-Host "       Acquired driver information from '$Hostname'" -ForegroundColor Green
                $Message = "acquired live driver information from '$Hostname'"
                Add-LogEntry $ShowProgress $OutputDirectory $Hostname "installed_drivers(live)" $Message
            }
            catch {
                Write-Host "    FAILURE: driver information could not be collected; another process may be using the same resources." -ForegroundColor Red
            }
        }
        function Get-Services
        {
            Param ($ShowProgress, $OutputDirectory, $Hostname)
            try {
                Write-Progress "Acquiring service information from '$Hostname'..."
                Get-WmiObject Win32_Service | Select-Object ProcessId, Name, State, Status, StartMode, ExitCode | Export-Csv $OutputDirectory\$Hostname\artefacts\artefacts\services.csv -NoTypeInformation
                (Get-Content -Path $OutputDirectory\$Hostname\artefacts\artefacts\services.csv) -Replace '"', '' | Set-Content $OutputDirectory\$Hostname\artefacts\artefacts\services.csv
                Write-Host "       Acquired service information from '$Hostname'" -ForegroundColor Green
                $Message = "acquired live service information from '$Hostname'"
                Add-LogEntry $ShowProgress $OutputDirectory $Hostname "installed_services(live)" $Message
            }
            catch {
                Write-Host "    FAILURE: service information could not be collected; another process may be using the same resources." -ForegroundColor Red
            }
        }
        function Get-Network
        {
            Param ($ShowProgress, $OutputDirectory, $Hostname)
            try {
                Write-Progress "Acquiring network information from '$Hostname'..."
                Get-NetTCPConnection | Select-Object CreationTime, State, LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, Name, InstallDate, EnabledDefault, AppliedSetting, Status | Export-Csv -Path $OutputDirectory\$Hostname\artefacts\artefacts\network.csv -NoTypeInformation
                (Get-Content -Path $OutputDirectory\$Hostname\artefacts\artefacts\network.csv) -Replace '"', '' | Set-Content $OutputDirectory\$Hostname\artefacts\artefacts\network.csv
                Write-Host "       Acquired network information from '$Hostname'" -ForegroundColor Green
                $Message = "acquired live network configuration from '$Hostname'"
                Add-LogEntry $ShowProgress $OutputDirectory $Hostname "network_configuration(live)" $Message
            }
            catch {
                Write-Host "    FAILURE: network information could not be collected; another process may be using the same resources." -ForegroundColor Red
            }
        }
        function Get-Tasks
        {
            Param ($ShowProgress, $OutputDirectory, $Hostname)
            try {
                Write-Progress "Acquiring scheduled task information from '$Hostname'..."
                $schtasks = 
                { 
                    schtasks.exe /query /V /FO CSV | ConvertFrom-Csv | Where-Object { $_.TaskName -ne "TaskName"}
                } 
                Invoke-Command -ScriptBlock $schtasks | Select-Object "Last Run Time`n`n", "     Next Run Time", TaskName, Status, "Logon Mode", Author, "Task To Run`n`n", "     Scheduled Task State`n`n", "     Run As User`n`n", "     Schedule Type", Days | Export-Csv $OutputDirectory\$Hostname\artefacts\artefacts\tasks.csv
                (Get-Content -Path $OutputDirectory\$Hostname\artefacts\artefacts\tasks.csv) -Replace '"([^"]+)","([^"]+)"(,"[^"]+",)"([^"]+)","([^"]+)"(,"[^"]+","[^"]+",)"([^"]+)","([^"]+)"(,"[^"]+",)"([^"]+)"', '$1,$2$3$4,$5$6$7,$8$9$10' | Set-Content $OutputDirectory\$Hostname\artefacts\artefacts\tasks.csv
                Write-Host "       Acquired scheduled task information from '$Hostname'" -ForegroundColor Green
                $Message = "acquired live scheduled tasks from '$Hostname'"
                Add-LogEntry $ShowProgress $OutputDirectory $Hostname "scheduled_tasks(live)" $Message
            }
            catch {
                Write-Host "    FAILURE: scheduled task information could not be collected; another process may be using the same resources." -ForegroundColor Red
            }
        }
        if ($Memory) {
            Get-Memory $ShowProgress $OutputDirectory $Hostname
        }
        Get-SystemInfo $ShowProgress $OutputDirectory $Hostname
        Get-Processes $ShowProgress $OutputDirectory $Hostname
        Get-Drivers $ShowProgress $OutputDirectory $Hostname
        Get-Services $ShowProgress $OutputDirectory $Hostname
        Get-Network $ShowProgress $OutputDirectory $Hostname
        Get-Tasks $ShowProgress $OutputDirectory $Hostname
    }
    function Get-Core
    {
        Param ($ShowProgress, $DriveLetter, $OutputDirectory, $Hostname)
        $Artefacts = @("`$MFT", "hiberfil.sys", "pagefile.sys", "Windows\AppCompat\Programs\Amcache.hve", "Windows\INF\setupapi.dev.log", "Windows\inf\setupapi.dev.log")
        ForEach ($Artefact in $Artefacts) {
            $ArtefactFile = $Artefact.Split("\\")[-1]
            if ($Artefact.Endswith("MFT")) {
                Write-Progress "Acquiring $ArtefactFile from '$Hostname'..."
                $global:ProgressPreference = "SilentlyContinue"
                Expand-Archive -LiteralPath "$OutputDirectory\tools\icat-sk-4.11.1-win32.zip" -DestinationPath "$OutputDirectory\tools\icat"
                $icat = {.\tools\icat\bin\icat.exe \\.\c: 0 > $Hostname\`$MFT}
                Invoke-Command -ScriptBlock $icat
                Remove-Item ".\tools\icat" -Recurse -Force
                $global:ProgressPreference = "Continue"
                Write-Host "       Acquired $ArtefactFile from '$Hostname'" -ForegroundColor Green
                $Message = "acquired '$ArtefactFile' from '$Hostname'"
                Add-LogEntry $ShowProgress $OutputDirectory $Hostname $ArtefactFile $Message
            }
            elseif ($Artefact.Endswith("hiberfil.sys") -Or $Artefact.Endswith("pagefile.sys") -Or $Artefact.Endswith("Amcache.hve") -Or $Artefact.Endswith("setupapi.dev.log")) {
                Write-Progress "Acquiring $ArtefactFile from '$Hostname'..."
                try {
                    Copy-Item $DriveLetter\$Artefact -Destination $OutputDirectory\$Hostname -Force -ErrorAction SilentlyContinue
                    $Message = "acquired '$ArtefactFile' from '$Hostname'"
                    Add-LogEntry $ShowProgress $OutputDirectory $Hostname $Artefact $Message
                }
                catch {
                    Write-Host "    FAILURE: $DriveLetter\$Artefact could not be collected; it may be being used by another process." -ForegroundColor Red
                }
            }
        }
    }
    function Get-Wmi
    {
        Param ($ShowProgress, $DriveLetter, $OutputDirectory, $Hostname)
        $Wmis = @("$DriveLetter\Windows\System32\wbem\Repository\")
        Write-Progress "Acquiring WMI evidence from '$Hostname'..."
        ForEach ($Wmi in Get-ChildItem -Path $Wmis -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied) {
            if ($Wmi.FullName.Endswith("OBJECTS.DATA") -Or $Wmi.FullName.Endswith("INDEX.BTR") -Or $Wmi.FullName.Endswith(".MAP")) {
                try {
                    Copy-Item $Wmi.FullName -Destination $OutputDirectory\$Hostname\artefacts\artefacts\raw\wmi -Force -ErrorAction SilentlyContinue
                    $Message = "acquired '$Wmi' WMI evidence from '$Hostname'"
                    Add-LogEntry $ShowProgress $OutputDirectory $Hostname $Wmi $Message
                }
                catch {
                    Write-Host "    FAILURE: WMI artefacts could not be collected; they may be being used by another process." -ForegroundColor Red
                }
            }
        }
        $Wmis = @("$DriveLetter\Windows\System32\wbem\AutoRecover\")
            ForEach ($Wmi in Get-ChildItem -Path $Wmis -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied) {
                if ($Wmi.FullName.Endswith(".MOF") -Or $Wmi.FullName.Endswith(".mof")) {
                try {
                    Copy-Item $Wmi.FullName -Destination $OutputDirectory\$Hostname\artefacts\artefacts\raw\wmi -Force -ErrorAction SilentlyContinue
                    Add-LogEntry $ShowProgress $OutputDirectory $Hostname $Wmi $Message
                }
                catch {
                    Write-Host "    FAILURE: WMI artefacts could not be collected; they may be being used by another process." -ForegroundColor Red
                }
            }
        }
        Write-Host "       Acquired WMI evidence from '$Hostname'" -ForegroundColor Green
    }
    function Get-Registry
    {
        Param ($ShowProgress, $OutputDirectory, $Hostname)
        $Hives = @("SAM", "SECURITY", "SOFTWARE", "SYSTEM")
        try {
            Write-Progress "Acquiring registry hives from '$Hostname'..."
            ForEach ($Hive in $Hives) {
                try {
                    reg save "HKLM\$Hive" "$OutputDirectory\$Hostname\artefacts\artefacts\raw\registry\$Hive" /y > $null
                    $Message = "acquired '$Hive' registry hive from '$Hostname'"
                    Add-LogEntry $ShowProgress $OutputDirectory $Hostname $Hive $Message
                }
                catch {
                    Write-Host "    FAILURE: "HKLM\$Hive" could not be collected; they may be being used by another process." -ForegroundColor Red
                }
            }
            ForEach ($SidPath in reg query "HKU") {
                $Sid = $SidPath.Split('\')[-1]
                if ($Sid.Startswith("S-") -And -Not $Sid.Endswith("_Classes")) {
                    try {
                        reg save "$SidPath" "$OutputDirectory\$Hostname\artefacts\artefacts\raw\registry\$Sid+NTUSER.DAT" /y > $null
                        $Message = "acquired 'NTUSER.DAT' ($Sid) registry hive from '$Hostname'"
                        Add-LogEntry $ShowProgress $OutputDirectory $Hostname "NTUSER.DAT ($Sid)" $Message
                    }
                    catch {
                        Write-Host "    FAILURE: "SidPath" NTUSER.DAT could not be collected; they may be being used by another process." -ForegroundColor Red
                    }
                }
            }
            ForEach ($SidPath in reg query "HKU") {
                $Sid = $SidPath.Split('\')[-1]
                if ($Sid.Endswith("_Classes")) {
                    try {
                        reg save "$SidPath" "$OutputDirectory\$Hostname\artefacts\artefacts\raw\registry\$Sid+UsrClass.DAT" /y > $null
                        $Message = "acquired 'UsrClass.DAT' ($Sid) registry hive from '$Hostname'"
                        Add-LogEntry $ShowProgress $OutputDirectory $Hostname "UsrClass.DAT ($Sid)" $Message
                    }
                    catch {
                        Write-Host "    FAILURE: "SidPath" UsrClass.DAT could not be collected; they may be being used by another process." -ForegroundColor Red
                    }
                }
            }
            Write-Host "       Acquired registry hives from '$Hostname'" -ForegroundColor Green
        }
        catch {
            Write-Host "    FAILURE: registry hives could not be collected; they may be being used by another process." -ForegroundColor Red
        }
    }
    function Get-Winevt
    {
        Param ($ShowProgress, $DriveLetter, $OutputDirectory, $Hostname)
        $Evts = @("$DriveLetter\Windows\System32\Winevt\Logs\")
        try {
            Write-Progress "Acquiring windows event logs from '$Hostname'..."
            ForEach ($Evt in Get-ChildItem -Path $Evts -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied) {
                if ($Evt.FullName.Endswith(".evtx")) {
                    try {
                        Copy-Item $Evt.FullName -Destination $OutputDirectory\$Hostname\artefacts\artefacts\raw\evt -Force -ErrorAction SilentlyContinue
                        $Message = "acquired '$Evt' event log from '$Hostname'"
                        Add-LogEntry $ShowProgress $OutputDirectory $Hostname $Evt $Message
                    }
                    catch {
                        Write-Host "    FAILURE: '$Evt' could not be collected; it may be being used by another process." -ForegroundColor Red
                    }
                }
            }
            Write-Host "       Acquired windows event logs from '$Hostname'" -ForegroundColor Green
        }
        catch {
            Write-Host "    FAILURE: windows event logs could not be collected; they may be being used by another process." -ForegroundColor Red
        }
    }
    function Get-Prefetch
    {
        Param ($ShowProgress, $DriveLetter, $OutputDirectory, $Hostname)
        $Prefetch = @("$DriveLetter\Windows\Prefetch\")
        try {
            Write-Progress "Acquiring prefetch files from '$Hostname'..."
            ForEach ($Pf in Get-ChildItem -Path $Prefetch -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied) {
                if ($Pf.FullName.Endswith(".pf")) {
                    try {
                        Copy-Item $Pf.FullName -Destination $OutputDirectory\$Hostname\artefacts\artefacts\raw\prefetch -Force -ErrorAction SilentlyContinue
                        $Message = "acquired '$Pf' prefetch file from '$Hostname'"
                        Add-LogEntry $ShowProgress $OutputDirectory $Hostname $Pf $Message
                    }
                    catch {
                        Write-Host "    FAILURE: '$Pf' could not be collected; it may be being used by another process." -ForegroundColor Red
                    }
                }
            }
            Write-Host "       Acquired prefetch files from '$Hostname'" -ForegroundColor Green
        }
        catch {
            Write-Host "    FAILURE: prefetch files could not be collected; they may be being used by another process." -ForegroundColor Red
        }
    }
    function Get-Users
    {
        Param ($ShowProgress, $DriveLetter, $OutputDirectory, $Hostname)
        function Get-Jumplists
        {
            Param ($ShowProgress, $OutputDirectory, $Hostname, $UserDirs)
            try {
                ForEach ($User in Get-ChildItem -Path $UserDirs -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied) {
                    Write-Progress "Acquiring jumplists for '$User' from '$Hostname'..."
                    ForEach ($UserArtefact in Get-ChildItem -Path $User.FullName -Force -Recurse -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied) {
                        if ($UserArtefact.FullName.Contains("AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations\") -Or $UserArtefact.FullName.Contains("AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations\")) {
                            try {
                                Copy-Item $UserArtefact.FullName -Destination "$OutputDirectory\$Hostname\artefacts\artefacts\raw\jumplists\$User+$UserArtefact" -Force -ErrorAction SilentlyContinue
                                $Message = "acquired jumplist file '$UserArtefact' for '$User' from '$Hostname'"
                                Add-LogEntry $ShowProgress $OutputDirectory $Hostname $UserArtefact $Message
                            }
                            catch {
                                Write-Host "    FAILURE: '$UserArtefact' for '$User' could not be collected; it may be being used by another process." -ForegroundColor Red
                            }
                        }
                    }
                    $JumplistFiles = Get-ChildItem $OutputDirectory\$Hostname\artefacts\artefacts\raw\jumplists
                    $User = [convert]::ToString($User)
                    if (Select-String -InputObject $JumplistFiles -Pattern $User) {
                        Write-Host "       Acquired jumplist evidence for '$User' from '$Hostname'" -ForegroundColor Green
                    }
                }
            }
            catch {
                Write-Host "    FAILURE: '$User' jumplists files could not be collected; they may be being used by another process." -ForegroundColor Red
            }
        }
        function Get-Browsers
        {
            Param ($ShowProgress, $DriveLetter, $Hostname, $UserDirs)
            try {
                ForEach ($User in Get-ChildItem -Path $UserDirs -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied) {
                    Write-Progress "Acquiring browser artefacts for '$User' from '$Hostname'..."
                    ForEach ($UserArtefact in Get-ChildItem -Path $User.FullName -Force -Recurse -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied) {
                        if ($UserArtefact.FullName.Endswith("AppData\Local\Microsoft\Edge\User Data\Default\History")) {
                            try {
                                Copy-Item $UserArtefact.FullName -Destination $OutputDirectory\$Hostname\artefacts\artefacts\raw\browsers\edge\$User+$UserArtefact -Force -ErrorAction SilentlyContinue
                                $Message = "acquired edge browser history for '$User' from '$Hostname'"
                                Add-LogEntry $ShowProgress $OutputDirectory $Hostname $UserArtefact $Message
                            }
                            catch {
                                Write-Host "    FAILURE: '$UserArtefact' for '$User' could not be collected; it may be being used by another process." -ForegroundColor Red
                            }
                            $BrowserFiles = (Get-ChildItem $OutputDirectory\$Hostname\artefacts\artefacts\raw\browsers\edge | Measure-Object).Count
                            $BrowserFiles = [convert]::ToInt32($BrowserFiles)
                            if ($BrowserFiles -ne 0) {
                                Write-Host "       Acquired edge browser history evidence for '$User' from '$Hostname'" -ForegroundColor Green
                            }
                        }
                        if ($UserArtefact.FullName.Endswith("AppData\Local\Google\Chrome\User Data\Default\History")) {
                            try {
                                Copy-Item $UserArtefact.FullName -Destination $OutputDirectory\$Hostname\artefacts\artefacts\raw\browsers\chrome\$User+$UserArtefact -Force -ErrorAction SilentlyContinue
                                $Message = "acquired chrome browser history for '$User' from '$Hostname'"
                                Add-LogEntry $ShowProgress $OutputDirectory $Hostname $UserArtefact $Message
                            }
                            catch {
                                Write-Host "    FAILURE: '$UserArtefact' for '$User' could not be collected; it may be being used by another process." -ForegroundColor Red
                            }
                            $BrowserFiles = (Get-ChildItem $OutputDirectory\$Hostname\artefacts\artefacts\raw\browsers\chrome | Measure-Object).Count
                            $BrowserFiles = [convert]::ToInt32($BrowserFiles)
                            if ($BrowserFiles -ne 0) {
                                Write-Host "       Acquired chrome browser history evidence for '$User' from '$Hostname'" -ForegroundColor Green
                            }
                        }
                        if ($UserArtefact.FullName.Endswith("AppData\Roaming\Mozilla\Firefox\Profiles\")) # need to copy folder from this location
                        {
                            try {
                                Copy-Item $UserArtefact.FullName -Destination $OutputDirectory\$Hostname\artefacts\artefacts\raw\browsers\firefox\$User+$UserArtefact -Force -ErrorAction SilentlyContinue
                                $Message = "acquired firefox browser history for '$User' from '$Hostname'"
                                Add-LogEntry $ShowProgress $OutputDirectory $Hostname $UserArtefact $Message
                            }
                            catch {
                                Write-Host "    FAILURE: '$UserArtefact' for '$User' could not be collected; it may be being used by another process." -ForegroundColor Red
                            }
                            $BrowserFiles = (Get-ChildItem $OutputDirectory\$Hostname\artefacts\artefacts\raw\browsers\firefox | Measure-Object).Count
                            $BrowserFiles = [convert]::ToInt32($BrowserFiles)
                            if ($BrowserFiles -ne 0) {
                                Write-Host "       Acquired firefox browser history evidence for '$User' from '$Hostname'" -ForegroundColor Green
                            }
                        }
                    }
                }
            }
            catch {
                Write-Host "    FAILURE: '$User' browser files could not be collected; they may be being used by another process." -ForegroundColor Red
            }
        }
        $UserDirs = @("$DriveLetter\Users\")
        Get-Jumplists $ShowProgress $OutputDirectory $Hostname $UserDirs
        Get-Browsers $ShowProgress $OutputDirectory $Hostname $UserDirs
    }
    Get-Volatile $ShowProgress $Memory $OutputDirectory $Hostname
    Get-Core $ShowProgress $DriveLetter $OutputDirectory $Hostname
    Get-Wmi $ShowProgress $DriveLetter $OutputDirectory $Hostname
    Get-Registry $ShowProgress $OutputDirectory $Hostname
    Get-Winevt $ShowProgress $DriveLetter $OutputDirectory $Hostname
    Get-Prefetch $ShowProgress $DriveLetter $OutputDirectory $Hostname
    Get-Users $ShowProgress $DriveLetter $OutputDirectory $Hostname
    Write-Progress -Activity "_" -Completed
}

function Optimize-Archive
{
    Param ($ShowProgress, $OutputDirectory, $Hostname)
    function Remove-Directories
    {
        Param ($ShowProgress, $OutputDirectory, $Hostname)
        $EmptyDirectories = @()
        ForEach ($SubDirectory in Get-ChildItem -Force -Literal $OutputDirectory\$Hostname -Directory) {
            $SubFiles = (Get-ChildItem $OutputDirectory\$Hostname\$SubDirectory | Measure-Object).Count
            $SubFiles = [convert]::ToInt32($SubFiles)
            if ($SubFiles -eq 0) {
                $EmptyDirectories += ,$SubDirectory.FullName
            }
            else {
                $SubDirectory = [convert]::ToString($SubDirectory)
                if ($SubDirectory -eq "browsers") {
                    ForEach ($BrowserDirectory in Get-ChildItem -Force -Literal $Hostname\$SubDirectory -Directory) {
                        $BrowserFiles = (Get-ChildItem $Hostname\$SubDirectory\$BrowserDirectory | Measure-Object).Count
                        $BrowserFiles = [convert]::ToInt32($BrowserFiles)
                        if ($BrowserFiles -eq 0) {
                            $EmptyDirectories += ,$BrowserDirectory.FullName
                        }
                    }
                }
            }
        }
        ForEach ($EachDirectory in $EmptyDirectories) {
            Remove-Item -Path $EachDirectory > $null
        }
    }
    Remove-Directories $ShowProgress $OutputDirectory $Hostname # remove empty artefact directories
    Remove-Directories $ShowProgress $OutputDirectory $Hostname # remove empty browser artefact directories
    $Result = (Get-ChildItem $OutputDirectory\$Hostname | Measure-Object).Count
    $Result = [convert]::ToInt32($Result)
    return $Result
}

function New-Archive
{
    Param ($EncryptionObject, $OutputDirectory, $ShowProgress, $Hostname, $Message, $ArchiveObject)
    Write-Host `r
    $SourcePath = Resolve-Path -Path $OutputDirectory\$Hostname\artefacts
    $ArchivePath = Resolve-Path -Path $OutputDirectory\$Hostname
    if ($EncryptionObject -eq "None") {
        $ArchiveFile = Join-Path -Path $ArchivePath -ChildPath "$Hostname.zip"
        if (Test-Path -LiteralPath $ArchiveFile) {
            Remove-Item -Path $ArchiveFile -Recurse > $null
        }
        Compress-Archive -Path $Hostname -DestinationPath $ArchiveFile
    }
    elseif ($EncryptionObject -eq "Key") {
        $ArchiveFile = Join-Path -Path $ArchivePath -ChildPath "$Hostname.zip"
        if (Test-Path -LiteralPath $ArchiveFile) {
            Remove-Item -Path $ArchiveFile -Recurse > $null
        }
        $SourceFile = Resolve-Path -Path $Hostname
        Exit
        Compress-7Zip -Path $SourceFile -ArchiveFileName $ArchiveFile -Format Zip
    }
    else {
        $ArchiveFile = Join-Path -Path $ArchivePath -ChildPath "$Hostname.7z"
        if (Test-Path -LiteralPath $ArchiveFile) {
            Remove-Item -Path $ArchiveFile -Recurse > $null
        }
        $ArchiveObject = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($ArchiveObject)
        $ArchiveObject = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ArchiveObject)
        Compress-7Zip -Path $SourcePath -ArchiveFileName $ArchiveFile -Format SevenZip -Password $ArchiveObject -EncryptFilenames
    }
    $ArchiveFile = $ArchiveFile.Split("\\")[-1]
    Write-Host "    Successfully created '$ArchiveFile'" -ForegroundColor White
    $Message = "archived artefacts from '$Hostname'"
    Add-LogEntry $ShowProgress $OutputDirectory $Hostname $ArchiveFile $Message
}

function Enter-LocalSession
{
    Param ($EncryptionObject, $OutputDirectory, $ShowProgress, $Memory, $DriveLetter, $Hostname, $ArchiveObject)
    $DriveLetter = New-Directories $OutputDirectory $Hostname
    "LastWriteTime,gandalf_host,gandalf_stage,gandalf_log_entry" | Set-Content $OutputDirectory\$Hostname\log.audit
    Write-Host "`n`n  -> Commencing artefact acquisition for: '$Hostname'`n    ----------------------------------------" -Foreground Gray
    $Message = "commencing artefact acquisition from '$Hostname'"
    Add-LogEntry $ShowProgress $OutputDirectory $Hostname "acquisition_commenced" $Message
    Get-Platform $ShowProgress $DriveLetter $OutputDirectory $Hostname
    Get-Artefacts $ShowProgress $Memory $DriveLetter $OutputDirectory $Hostname
    $Result = Optimize-Archive $OutputDirectory $Hostname
    if ($Result -gt 0) {
        New-Archive $EncryptionObject $OutputDirectory $ShowProgress $Hostname $Message $ArchiveObject
    }
    else {
        Write-Host "`n    Unfortunately, no artefacts could be collected`n`n"
        Exit
    }
}

function Enter-RemoteSession
{
    Param ($EncryptionObject, $OutputDirectory, $ShowProgress, $Memory, $DriveLetter, $Hostname, $ArchiveObject)
    #Open-RemoteSession
    Enter-LocalSession $EncryptionObject $OutputDirectory $ShowProgress $Memory $DriveLetter $Hostname $ArchiveObject
    #Copy-RemoteArchive - send archive back/collect archive from remote host
    #Close-RemoteSession
}

<#
    Calling Functions
#>
$DateTime = "{0}" -f (Get-Date)
$StartTime = Get-Date -Date $DateTime -UFormat %s
$StartTime = [convert]::ToInt32($StartTime)
$global:ProgressPreference = "Continue"
Clear-Host
Format-Art
$EncryptionObject, $Acquisition, $OutputDirectory = Set-Defaults $EncryptionObject $Acquisition $OutputDirectory
if ($EncryptionObject -eq "Key") {
    Get-Modules $EncryptionObject
    $ArchiveObject = Read-Host "     Provide path to PGP Public Key for archive encryption"
}
elseif ($EncryptionObject -eq "Password") {
    Get-Modules $EncryptionObject
    $ArchiveObject = Read-Host "     Enter Password for archive encryption" -AsSecureString
}
else {
    $ArchiveObject = "None"
}
Write-Host `r
if ($Acquisition -eq "Local")
{
    $Hostlist = $env:COMPUTERNAME
    ForEach ($Hostname in $Hostlist) {
        Enter-LocalSession $EncryptionObject $OutputDirectory $ShowProgress $Memory $DriveLetter $Hostname $ArchiveObject
    }
}
else
{
    # require a list of hosts - in the same current directory called hosts.list; assign that to $Hostlist
    ForEach ($Hostname in $Hostlist) {
        Enter-RemoteSession $EncryptionObject $OutputDirectory $ShowProgress $Memory $DriveLetter $Hostname $ArchiveObject
    }
}
<#if ($EncryptionObject -ne "None") {
    if (Get-Module -ListAvailable -Name 7Zip4PowerShell) {
        Remove-Module -Name 7Zip4PowerShell -Force
        Uninstall-Module -Name 7Zip4PowerShell -Force
    }
    if (Get-Module -ListAvailable -Name PoShKeePass) {
        Remove-Module -Name PoShKeePass -Force
        Uninstall-Module -Name PoShKeePass -Force
    }
}#>
Write-Host ""
$DateTime = "{0}" -f (Get-Date)
$EndTime = Get-Date -Date $DateTime -UFormat %s
$EndTime = [convert]::ToInt32($EndTime)
$TimeDifference = $EndTime-$StartTime
$ElapsedTime = Format-Time $TimeDifference
Write-Host "`n`n  -> Finished. Total elapsed time: $ElapsedTime`n    ----------------------------------------" -Foreground Gray
Write-Host "      Completed artefact acquisition for:"
ForEach ($EachHost in $Hostlist) {
    Write-Host "       - $Hostname"
    Remove-Item -Path $OutputDirectory\$Hostname\artefacts -Recurse > $null
}
Write-Host `n`n
