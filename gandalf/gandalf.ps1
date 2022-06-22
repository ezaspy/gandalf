<#
.SYNOPSIS
Collects forensic artefacts on Windows hosts; compatible with elrond
Version: 0.1
Author : ezaspy
License: MIT
.DESCRIPTION
.PARAMETER Deployment
.PARAMETER Package
.PARAMETER Destination
.EXAMPLE
The following example invokes all of the parameters with the default arguments - -Deployment Local -Package Key -Destination C:\TEMP\Gandalf.
PS C:\> .\Gandalf.ps1
.EXAMPLE
The following example invokes all of the parameters with the default arguments, explicitly stated.
PS C:\> .\Gandalf.ps1 -Deployment Local -Package .\id_rsa.pub -Destination C:\TEMP\Gandalf
.EXAMPLE
The following example invokes all of the parameters with non-default arguments - deployment against a remote host, specified by IP or Hostname, a (less secure) password-protected package, and outputted to the root directory on the D: drive.
PS C:\> .\Gandalf.ps1 -Deployment <REMOTE_HOST> -Package Password -Destination D:
.NOTES
.INPUTS
.OUTPUTS
.LINK
#>


Param($Deployment, $Package, $Destination)

function New-Directories
{
    $Hostname = $env:COMPUTERNAME
    Remove-Item -Path $Hostname -Recurse > $null
    New-Item -Path $Hostname -ItemType Directory > $null
    if (Test-Path -Path $Hostname)
    {
        New-Item -Path $Hostname\wmi -ItemType Directory > $null
        New-Item -Path $Hostname\registry -ItemType Directory > $null
        New-Item -Path $Hostname\evt -ItemType Directory > $null
        New-Item -Path $Hostname\prefetch -ItemType Directory > $null
        New-Item -Path $Hostname\jumplists -ItemType Directory > $null
        New-Item -Path $Hostname\browsers -ItemType Directory > $null
        New-Item -Path $Hostname\browsers\edge -ItemType Directory > $null
        New-Item -Path $Hostname\browsers\chrome -ItemType Directory > $null
        New-Item -Path $Hostname\browsers\firefox -ItemType Directory > $null
    }
    Clear-Host
    return $Hostname
}

function Format-Art
{
    $quotes = @("     Not come the days of the King.`n     May they be blessed.`n`n", "     If my old gaffer could see me now.`n`n", "     I'll have no pointy-ear outscoring me!`n`n", "     I think there is more to this hobbit, than meets the eye.`n`n", "     You are full of surprises Master Baggins.`n`n", "     One ring to rule them all, one ring to find them.`n     One ring to bring them all, and in the darkness bind them.`n`n", "     The world is changed.`n     I feel it in the water.`n     I feel it in the earth.`n     I smell it in the air.`n`n", "     Who knows? Have patience. Go where you must go, and hope!`n`n", "     All we have to decide is what to do with the time that is given us.`n`n", "     Deeds will not be less valiant because they are unpraised.`n`n", "     It is not the strength of the body, but the strength of the spirit.`n`n", "     But in the end it’s only a passing thing, this shadow; even darkness must pass.`n`n", "     It’s the job that’s never started as takes longest to finish.`n`n", "     Coward? Not every man's brave enough to wear a corset!`n`n", "     Bilbo was right. You cannot see what you have become.`n`n", "     He is known in the wild as Strider.`n     His true name, you must discover for yourself.`n`n", "     Legolas said you fought well today. He's grown very fond of you.`n`n", "     You will take NOTHING from me, dwarf.`n     I laid low your warriors of old.`n     I instilled terror in the hearts of men.`n     I AM KING UNDER THE MOUNTAIN!`n`n", "     You've changed, Bilbo Baggins.`n     You're not the same Hobbit as the one who left the Shire...`n`n", "     The world is not in your books and maps. It's out there.`n`n", "     That is private, keep your sticky paws off! It's not ready yet!`n`n", "     I wish you all the luck in the world. I really do.`n`n", "     No. No. You can't turn back now. You're part of the company.`n     You're one of us.`n`n", "     True courage is about knowing not when to take a life, but when to spare one.`n`n", "     The treacherous are ever distrustful.`n`n", "     Let him not vow to walk in the dark, who has not seen the nightfall.`n`n", "     He that breaks a thing to find out what it is has left the path of wisdom.`n`n", "     I was there, Gandalf.`n     I was there three thousand years ago, when Isildur took the ring.`n     I was there the day the strength of Men failed.`n`n", "     I don't know half of you half as well as I should like,`n     and I like less than half of you half as well as you deserve.`n`n", "     Certainty of death. Small chance of success.`n     What are we waiting for?`n`n", "     Do not spoil the wonder with haste!`n`n", "     It came to me, my own, my love... my... preciousssss.`n`n", "     One does not simply walk into Mordor...`n`n", "     Nine companions. So be it. You shall be the fellowship of the ring.`n`n", "     You have my sword. You have my bow; And my axe!`n`n", "     Build me an army, worthy of Mordor!`n`n", "     Nobody tosses a Dwarf!`n`n", "     If in doubt, Meriadoc, always follow your nose.`n`n", "     This is beyond my skill to heal; he needs Elven medicine.`n`n", "     No, thank you! We don't want any more visitors, well-wishers or distant relations!`n`n", "     Mordor! I hope the others find a safer road.`n`n", "     YOU SHALL NOT PASS!`n`n", "     You cannot hide, I see you!`n     There is no life, after me.`n     Only!.. Death!`n`n", "     A wizard is never late, Frodo Baggins.`n     Nor is he early.`n     He arrives precisely when he means to.`n`n", "     Is it secret?! Is it safe?!`n`n", "     Even the smallest person can change the course of the future.`n`n", "     We must move on, we cannot linger.`n`n", "     I wish the ring had never come to me. I wish none of this had happened.`n`n", "     Moonlight drowns out all but the brightest stars.`n`n", "     A hunted man sometimes wearies of distrust and longs for friendship.`n`n", "     The world is indeed full of peril and in it there are many dark places.`n`n", "     Someone else always has to carry on the story.`n`n", "     Your time will come. You will face the same Evil, and you will defeat it.`n`n", "     It is useless to meet revenge with revenge; it will heal nothing.`n`n", "     Despair is only for those who see the end beyond all doubt. We do not.`n`n", "     Anyways, you need people of intelligence on this sort of… mission… quest… thing.`n`n", "     Oh, it’s quite simple. If you are a friend, you speak the password, and the doors will open.`n`n", "     The wise speak only of what they know.`n`n", "     Not all those who wander are lost.`n`n", "     It's the deep breath before the plunge.`n`n")
    Write-Host "
    `n`n`n`n
           ____                      .___        .__    _____  
          / ___\ _____     ____    __| _/_____   |  | _/ ____\ 
         / /_/  >\__  \   /    \  / __ | \__  \  |  | \   __\  
         \___  /  / __ \_|   |  \/ /_/ |  / __ \_|  |__|  |    
        /_____/  (____  /|___|  /\____ | (____  /|____/|__|    
                              \/      \/      \/      \/               
    " -Foreground Magenta
    $quote = Get-Random -InputObject $quotes
    Write-Host $quote -Foreground Magenta
}

function Get-Artefacts
{
    param ($Hostname)
    function Get-Volatile
    {
        param ($Hostname)
        function Get-Processes
        {
            param ($Hostname)
            Write-Progress "Collecting process information..."
            Get-CimInstance -ClassName Win32_Process | Select-Object ProcessId, Name, HandleCount | Export-Csv -Path $Hostname\processes.csv -NoTypeInformation
            (Get-Content -Path $Hostname\processes.csv) -Replace '"(\d+)"(,")([^"]+",)"(\d+)"', '$1$2$3$4' | Set-Content $Hostname\processes.csv
        }

        function Get-Drivers
        {
            param ($Hostname)
            Write-Progress "Collecting driver information..."
            Get-CimInstance -ClassName Win32_SystemDriver | Select-Object DisplayName, Name, State, Status, Started | Export-Csv -Path $Hostname\drivers.csv -NoTypeInformation
            (Get-Content -Path $Hostname\drivers.csv) -Replace ',"([^"]+)","([^"]+)","([^"]+)","([^"]+)', ',$1,$2,$3,$4' | Set-Content $Hostname\drivers.csv
        }

        function Get-Services
        {
            param ($Hostname)
            Write-Progress "Collecting service information..."
            Get-WmiObject Win32_Service | Select-Object ProcessId, Name, State, Status, StartMode, ExitCode | Export-Csv $Hostname\services.csv -NoTypeInformation
            (Get-Content -Path $Hostname\services.csv) -Replace '"', '' | Set-Content $Hostname\services.csv
        }

        function Get-Network
        {
            param ($Hostname)
            Write-Progress "Collecting network information..."
            Get-NetTCPConnection | Select-Object CreationTime, State, LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, Name, InstallDate, EnabledDefault, AppliedSetting, Status | Export-Csv -Path $Hostname\network.csv -NoTypeInformation
            (Get-Content -Path $Hostname\network.csv) -Replace '"', '' | Set-Content $Hostname\network.csv
        }

        function Get-Tasks
        {
            param ($Hostname)
            Write-Progress "Collecting scheduled task information..."
            $schtasks = 
            { 
                schtasks.exe /query /V /FO CSV | ConvertFrom-Csv | Where-Object { $_.TaskName -ne "TaskName"}
            } 
            Invoke-Command -ScriptBlock $schtasks | Select-Object "Last Run Time`n`n", "     Next Run Time", TaskName, Status, "Logon Mode", Author, "Task To Run`n`n", "     Scheduled Task State`n`n", "     Run As User`n`n", "     Schedule Type", Days | Export-Csv $Hostname\tasks.csv
            (Get-Content -Path $Hostname\tasks.csv) -Replace '"([^"]+)","([^"]+)"(,"[^"]+",)"([^"]+)","([^"]+)"(,"[^"]+","[^"]+",)"([^"]+)","([^"]+)"(,"[^"]+",)"([^"]+)"', '$1,$2$3$4,$5$6$7,$8$9$10' | Set-Content $Hostname\tasks.csv
        }

        Get-Processes $Hostname
        Get-Drivers $Hostname
        Get-Services $Hostname
        Get-Network $Hostname
        Get-Tasks $Hostname
    }

    function Get-Core
    {
        param ($Hostname)
        $Artefacts = @("C:\`$MFT", "C:\hiberfil.sys", "C:\pagefile.sys", "C:\Windows\AppCompat\Programs\Amcache.hve", "C:\Windows\inf\setupapi.dev.log")
        foreach ($Artefact in $Artefacts)
        {
            $ArtefactFile = $Artefact.Split("\\")[-1]
            Write-Progress "Collecting $ArtefactFile..."
            if ($Artefact.Endswith("MFT"))
            {
                $global:ProgressPreference = "SilentlyContinue"
                Remove-Item ".\tsk*" -Recurse -Force
                Start-BitsTransfer -Source "https://github.com/sleuthkit/sleuthkit/releases/download/sleuthkit-4.11.1/sleuthkit-4.11.1-win32.zip" -Destination tsk.zip
                Expand-Archive -LiteralPath tsk.zip -DestinationPath tsk
                $icat = {.\tsk\sleuthkit-4.11.1-win32\bin\icat.exe \\.\c: 0 > $Hostname\`$MFT}
                Invoke-Command -ScriptBlock $icat
                Remove-Item ".\tsk*" -Recurse -Force
                $global:ProgressPreference = "Continue"
            }
            elseif ($Artefact.Endswith("hiberfil.sys") -Or $Artefact.Endswith("pagefile.sys") -Or $Artefact.Endswith("Amcache.hve") -Or $Artefact.Endswith("setupapi.dev.log"))
            {
                Write-Progress "Collecting $ArtefactFile..."
                try
                {
                    Copy-Item $Artefact -Destination $Hostname -Force -ErrorAction SilentlyContinue
                }
                catch
                {
                    Write-Host "  [*] COLLECTION FAILURE: $ArtefactFile cannot be collect; it is being used by another process." -ForegroundColor Red -BackgroundColor Black
                }
            }
        }
    }

    function Get-Wmi
    {
        param ($Hostname)
        $Wmis = @("C:\Windows\System32\wbem\Repository\")
        Write-Progress "Collecting WMI evidence..."
        foreach ($Wmi in Get-ChildItem -Path $Wmis -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied)
        {
            if ($Wmi.FullName.Endswith("OBJECTS.DATA") -Or $Wmi.FullName.Endswith("INDEX.BTR") -Or $Wmi.FullName.Endswith(".MAP"))
            {
                Copy-Item $Wmi.FullName -Destination $Hostname\wmi -Force -ErrorAction SilentlyContinue
            }
        }
        $Wmis = @("C:\Windows\System32\wbem\AutoRecover\")
            foreach ($Wmi in Get-ChildItem -Path $Wmis -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied)
            {
                if ($Wmi.FullName.Endswith(".MOF") -Or $Wmi.FullName.Endswith(".mof"))
            {
                Copy-Item $Wmi.FullName -Destination $Hostname\wmi -Force -ErrorAction SilentlyContinue
            }
        }
    }

    function Get-Registry
    {
        param ($Hostname)
        $Hives = @("SAM", "SECURITY", "SOFTWARE", "SYSTEM")
        Write-Progress "Collecting registry hives..."
        foreach ($Hive in $Hives)
        {
            reg save "HKLM\$Hive" "$Hostname\registry\$Hive" /y > $null
        }
        foreach ($SidPath in reg query "HKU")
        {
            $Sid = $SidPath.Split('\')[-1]
            if ($Sid.Startswith("S-") -And -Not $Sid.Endswith("_Classes"))
            {
                reg save "$SidPath" "$Hostname\registry\$Sid+NTUSER.DAT" /y > $null
            }
        }
        foreach ($SidPath in reg query "HKU")
        {
            $Sid = $SidPath.Split('\')[-1]
            if ($Sid.Endswith("_Classes"))
            {
                reg save "$SidPath" "$Hostname\registry\$Sid+UsrClass.DAT" /y > $null
            }
        }
    }

    function Get-Winevt
    {
        param ($Hostname)
        $Evts = @("C:\Windows\System32\Winevt\Logs\")
        Write-Progress "Collecting Windows Event Logs..."
        foreach ($Evt in Get-ChildItem -Path $Evts -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied)
        {
            if ($Evt.FullName.Endswith(".evtx"))
            {
                Copy-Item $Evt.FullName -Destination $Hostname\evt -Force -ErrorAction SilentlyContinue
            }
        }
    }

    function Get-Prefetch
    {
        param ($Hostname)
        $Prefetch = @("C:\Windows\Prefetch\")
        Write-Progress "Collecting Prefetch files..."
        foreach ($Pf in Get-ChildItem -Path $Prefetch -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied)
        {
            if ($Pf.FullName.Endswith(".pf"))
            {
                Copy-Item $Pf.FullName -Destination $Hostname\prefetch -Force -ErrorAction SilentlyContinue
            }
        }
    }

    function Get-Users
    {
        param ($Hostname)
        function Get-Jumplists
        {
            param ($Hostname)
            $UserDirs = @("C:\Users\")
            foreach ($User in Get-ChildItem -Path $UserDirs -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied)
            {
                Write-Progress "Collecting jumplists for $User..."
                foreach ($UserArtefact in Get-ChildItem -Path $User.FullName -Force -Recurse -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied)
                {
                    if ($UserArtefact.FullName.Contains("AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations") -Or $UserArtefact.FullName.Contains("AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations"))
                    {
                        Copy-Item $UserArtefact.FullName -Destination $Hostname\jumplists\$User+$UserArtefact -Force -ErrorAction SilentlyContinue
                    }
                }
            }
        }
        
        function Get-Browsers
        {
            param ($Hostname)
            $UserDirs = @("C:\Users\")
            foreach ($User in Get-ChildItem -Path $UserDirs -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied)
            {
                Write-Progress "Collecting browser artefacts for $User..."
                foreach ($UserArtefact in Get-ChildItem -Path $User.FullName -Force -Recurse -ErrorAction SilentlyContinue -ErrorVariable PermissionDenied)
                {
                    if ($UserArtefact.FullName.Endswith("AppData\Local\Microsoft\Edge\User Data\Default\History"))
                    {
                        Copy-Item $UserArtefact.FullName -Destination $Hostname\browsers\edge\$User+$UserArtefact -Force -ErrorAction SilentlyContinue
                    }
                    if ($UserArtefact.FullName.Endswith("AppData\Local\Google\Chrome\User Data\Default\History"))
                    {
                        Copy-Item $UserArtefact.FullName -Destination $Hostname\browsers\chrome\$User+$UserArtefact -Force -ErrorAction SilentlyContinue
                    }
                    if ($UserArtefact.FullName.Endswith("AppData\Roaming\Mozilla\Firefox\Profiles\")) # need to copy folder from this location
                    {
                        Copy-Item $UserArtefact.FullName -Destination $Hostname\browsers\firefox\$User+$UserArtefact -Force -ErrorAction SilentlyContinue
                    }
                }
            }
        }
        Get-Jumplists $Hostname
        Get-Browsers $Hostname
    }

    Get-Volatile $Hostname
    Get-Core $Hostname
    Get-Wmi $Hostname
    Get-Registry $Hostname
    Get-Winevt $Hostname
    Get-Prefetch $Hostname
    Get-Users $Hostname
}

$Hostname = New-Directories
Format-Art

if ($Deployment -eq $null)
{
    $Deployment = "Local"
}

if ($Package -eq $null)
{
    $Package = ".\id_rsa.pub"
}

if ($Destination -eq $null)
{
    $Destination = "C:\TEMP\Gandalf"
}

if ($Deployment -eq "Local")
{
    if (-not (Test-Path -LiteralPath $Destination))
    {
        New-Item -Path $Destination -ItemType Directory -ErrorAction Stop | Out-Null
    }
}

$global:ProgressPreference = "Continue"
Get-Artefacts $Hostname
Remove-Item $Destination\$Hostname -Recurse -Force
Move-Item $Hostname $Destination\$Hostname
Write-Host `n`n