<#
 .Synopsis
 Collects forensic artefacts on Windows hosts; compatible with elrond
 Version: 1.0
 Author : ezaspy
 License: MIT
 .Description
 Collects digital forensic artefacts from Windows hosts. Output is compatible
  with elrond (https://github.com/ezaspy/elrond)
 .Parameter EncryptionObject
 Method of encryption used for archive file - Key, Password or None
 .Parameter Acquisition
 Method of acquisition - either Remote or Local
 .Parameter OutputDirectory
 Destination directory of where the collected will be stored
 .Parameter Memory
 Collect a memory dump
 .Parameter ShowProgress
 Print progress of individual artefact acquisition to screen
 .Parameter CollectFiles
 Collect files containing string (provided in files.list) in file name
 .Example
 The following example invokes all of the parameters with the default arguments;
   -EncryptionObject Key -Acquisition Local -OutputDirectory C:\TEMP\gandalf\gandalf
  PS C:\> .\Enter-Gandalf.ps1
 .Example
 The following example invokes all of the parameters with the default arguments;
  explicitly stated:
  PS C:\> .\Enter-Gandalf.ps1 -EncryptionObject Key -Acquisition Local -OutputDirectory C:\TEMP\gandalf\gandalf
 .Example
 The following example invokes all of the parameters with non-default arguments;
  deployment against a remote host, specified by IP or Hostname, a (less secure) 
  password-protected package, and outputted to the root directory on the D: drive.
  PS C:\> .\Gandalf.ps1 -EncryptionObject Password -Acquisition <REMOTE_HOST> -OutputDirectory D: -Memory -ShowProgress
#>
Param(
    [Parameter(Mandatory = $True, Position = 0)][string]$EncryptionObject,
    [Parameter(Position = 1)][string]$Acquisition,
    [Parameter(Position = 2)][string]$OutputDirectory,
    [Parameter(Position = 3)][switch]$Memory,
    [Parameter(Position = 4)][switch]$ShowProgress,
    [Parameter(Position = 5)][switch]$CollectFiles
)

function Format-Art {
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

function Format-Time {
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

function Set-Defaults {
    Param ($EncryptionObject, $Acquisition, $OutputDirectory)
    if ($null -eq $Acquisition -Or $Acquisition -eq "" -Or $Acquisition -eq "Local") {
        $Acquisition = "Local"
    }
    else {
        $Acquisition = "Remote"
    }
    if ($EncryptionObject -eq "Key" -Or $EncryptionObject -eq "Password") {
        if ($EncryptionObject -eq "Key") {
            Write-Host "     You have chosen to use Key-based encrpytion but unfortunately this is not yet supported. Please try again`n`n"
            Exit
        }
        $ConfirmEncryption = Read-Host "     You have chosen to use encrpytion when archiving the artefacts. Although this is highly recommended, you will need an Internet connection on each endpoint, to download the additional modules.`n      Do you wish to proceed? Y/n [Y] "
        if ($ConfirmEncryption -eq "n") {
            Write-Host "      Please try again with the " -NoNewLine; Write-Host "-EncryptionObject" -NoNewLine -Foreground Magenta; Write-Host " parameter set to 'None'`n`n"
            Exit
        }
        Write-Host `r
    }
    elseif ($EncryptionObject -eq "None") {
        if ($Acquisition -eq "Local") {
            $ConfirmNoEncryption = Read-Host "     You have chosen to use no encrpytion when archiving the artefacts. This is not recommended.`n      Are you sure you want to proceed? y/N [N] "
            if ($ConfirmNoEncryption -ne "y") {
                Write-Host "      Please try again with the " -NoNewLine; Write-Host "-EncryptionObject" -NoNewLine -Foreground Magenta; Write-Host " parameter set to 'Key' or 'Password'`n`n"
                Exit
            }
        }
    }
    else {
        Write-Host "    '$EncryptionObject' is not a valid option for the -EncryptionObject parameter. You can choose from 'Key' (Most Secure), 'Password' or 'None' (Least Secure)`n`n"
        Exit
    }
    if ($null -eq $OutputDirectory -Or $OutputDirectory -eq "") {
        $OutputDirectory = "C:\TEMP\gandalf\gandalf"
    }
    else {
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

function Set-ArtefactParams {
    Param ($EncryptionObject, $OutputDirectory, $ShowProgress, $Memory, $Hostname, $ArchiveObject, $CollectFiles)
    $ArtefactParams = "Param(`$EncryptionObject = '$EncryptionObject', `$OutputDirectory = '$OutputDirectory', `$ShowProgress = '$ShowProgress', `$Memory = '$Memory', `$Hostname = '$Hostname', `$ArchiveObject = '$ArchiveObject', `$CollectFiles = '$CollectFiles')"
    Add-Content -Path "C:\TEMP\gandalf\gandalf\tools\Invoke-ArtefactAcquisition.ps1" -Value $ArtefactParams
    $ArtefactCollection = Get-Content -Path "C:\TEMP\gandalf\gandalf\shire\Set-ArtefactCollection"
    Add-Content -Path "C:\TEMP\gandalf\gandalf\tools\Invoke-ArtefactAcquisition.ps1" -Value $ArtefactCollection
}

function Invoke-RemoteArtefactCollection {
    Param ($EncryptionObject, $OutputDirectory, $ShowProgress, $Memory, $DriveLetter, $Hostname, $Session, $ArchiveObject)
    Invoke-Command -Session $Session -ScriptBlock { New-Item -Path C:\TEMP\gandalf -ItemType Directory > $null }; Invoke-Command -Session $Session -ScriptBlock { New-Item -Path C:\TEMP\gandalf\gandalf -ItemType Directory > $null }; Invoke-Command -Session $Session -ScriptBlock { New-Item -Path C:\TEMP\gandalf\gandalf\tools -ItemType Directory > $null }
    if ($Memory) {
        Copy-Item -ToSession $Session -Path "C:\TEMP\gandalf\gandalf\tools" -Destination "C:\TEMP\gandalf\gandalf\tools" -Force -Recurse
    }
    else {
        Copy-Item -ToSession $Session -Path "C:\TEMP\gandalf\gandalf\tools\icat-sk-4.11.1-win32.zip" -Destination "C:\TEMP\gandalf\gandalf\tools\icat-sk-4.11.1-win32.zip" -Force
    }
    Copy-Item -ToSession $Session -Path "C:\TEMP\gandalf\README.md" -Destination "C:\TEMP\gandalf\README.md" -Force; Copy-Item -ToSession $Session -Path "C:\TEMP\gandalf\LICENSE" -Destination "C:\TEMP\gandalf\LICENSE" -Force; Copy-Item -ToSession $Session -Path "C:\TEMP\gandalf\gandalf\tools\Invoke-ArtefactAcquisition.ps1" -Destination "C:\TEMP\gandalf\gandalf\tools\Invoke-ArtefactAcquisition.ps1" -Force
    Invoke-Command -Session $Session -FilePath C:\TEMP\gandalf\gandalf\tools\.\Invoke-ArtefactAcquisition.ps1
    Remove-PSSession -Session $Session
    Invoke-RemoteArchiveCollection $OutputDirectory $Hostname $ArchiveObject
}

function Invoke-RemoteArchiveCollection {
    Param ($OutputDirectory, $Hostname, $ArchiveObject)
    $Session = New-PSSession -ComputerName $Hostname -Credential $RemoteCredentials
    Write-Progress "Collecting acquired artefacts from '$Hostname'..."
    New-Item -Path $OutputDirectory\acquisitions -ItemType Directory > $null; New-Item -Path $OutputDirectory\acquisitions\$Hostname -ItemType Directory > $null
    Copy-Item -FromSession $Session "$OutputDirectory\$Hostname\log.audit" -Destination "$OutputDirectory\acquisitions\$Hostname\log.audit" -Force > $null 2>&1; Copy-Item -FromSession $Session "$OutputDirectory\$Hostname\meta.audit" -Destination "$OutputDirectory\acquisitions\$Hostname\meta.audit" -Force > $null 2>&1
    Copy-Item -FromSession $Session "$OutputDirectory\$Hostname\$Hostname.zip" -Destination "$OutputDirectory\acquisitions\$Hostname\$Hostname.zip" -Force > $null 2>&1
    Copy-Item -FromSession $Session "$OutputDirectory\$Hostname\$Hostname.7z" -Destination "$OutputDirectory\acquisitions\$Hostname\$Hostname.7z" -Force > $null 2>&1
    Invoke-Command -Session $Session -ScriptBlock { Remove-Item -Path C:\TEMP\gandalf -Recurse }
    Remove-Item -Path "C:\TEMP\gandalf\gandalf\tools\Invoke-ArtefactAcquisition.ps1"
    Remove-PSSession -Session $Session
    Write-Host "   -> Collected acquired artefacts from '$Hostname'"
}

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
if ($Acquisition -eq "Local") {
    $Hostlist = $env:COMPUTERNAME
    ForEach ($Hostname in $Hostlist) {
        Set-ArtefactParams $EncryptionObject $OutputDirectory $ShowProgress $Memory $Hostname $ArchiveObject $CollectFiles
        C:\TEMP\gandalf\gandalf\tools\.\Invoke-ArtefactAcquisition.ps1
        #Remove-Item -Path $OutputDirectory\$Hostname\artefacts -Recurse > $null
    }
}
else {
    $RemoteCredentials = $host.ui.PromptForCredential("Local Admin authentication required", "Please enter credentials for PowerShell remoting", "", "")
    $Hostlist = Get-Content "C:\TEMP\gandalf\gandalf\shire\hosts.list"
    ForEach ($Hostname in $Hostlist) {
        Set-ArtefactParams $EncryptionObject $OutputDirectory $ShowProgress $Memory $Hostname $ArchiveObject $CollectFiles
        Write-Host "     Attempting to connect to '$Hostname'..."
        $Session = New-PSSession -ComputerName $Hostname -Credential $RemoteCredentials
        Write-Host "      Session opened for '$Hostname'"
        Invoke-RemoteArtefactCollection $EncryptionObject $OutputDirectory $ShowProgress $Memory $DriveLetter $Hostname $Session $ArchiveObject
        #Linux hosts - Invoke-Command -HostName UserA@LinuxServer01 -ScriptBlock { Get-MailBox * } -KeyFilePath /UserA/UserAKey_rsa
    }
}
$DateTime = "{0}" -f (Get-Date)
$EndTime = Get-Date -Date $DateTime -UFormat %s
$EndTime = [convert]::ToInt32($EndTime)
$TimeDifference = $EndTime - $StartTime
$ElapsedTime = Format-Time $TimeDifference
Write-Host "`n`n  -> Finished. Total elapsed time: $ElapsedTime`n    ----------------------------------------" -Foreground Gray
Write-Host "      gandalf completed for:"
ForEach ($EachHost in $Hostlist) {
    Write-Host "       - $Hostname"
}
Write-Host `n`n
