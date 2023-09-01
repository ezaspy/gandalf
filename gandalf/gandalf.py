#!/usr/bin/env python3 -tt
import argparse
import base64
import getpass
import os
import paramiko
import random
import shutil
import socket
import subprocess
import sys
import time
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from scp import SCPClient


parser = argparse.ArgumentParser()
parser.add_argument(
    "EncryptionMethod",
    help="Encrpytion Method - Key (recommended), Password or None",
)
parser.add_argument(
    "AcquisitionMethod",
    help="Acquisition Method - Local or Remote",
)
parser.add_argument(
    "-O",
    "--OutputDirectory",
    nargs="?",
    help="Directory location to output the artefact archive",
    const=True,
    default=False,
)
parser.add_argument(
    "-M",
    "--Memory",
    help="Acquire live memory",
    action="store_const",
    const=True,
    default=False,
)
parser.add_argument(
    "-A",
    "--AccessTimes",
    help="Obtain Last Access Times for every file",
    action="store_const",
    const=True,
    default=False,
)
parser.add_argument(
    "-F",
    "--CollectFiles",
    help="Collect specific files, anywhere in the fileystem",
    action="store_const",
    const=True,
    default=False,
)

args = parser.parse_args()
encryption_method = args.EncryptionMethod
acquisition_method = args.AcquisitionMethod
output_dir = args.OutputDirectory
mem = args.Memory
access_times = args.AccessTimes
files = args.CollectFiles

system_artefacts = {
    "/.Trashes/": "trash",
    "/Library/Logs/": "logs",
    "/Library/Preferences/": "plists",
    "/Library/LaunchAgents/": "plists",
    "/Library/LaunchDaemons/": "plists",
    "/Library/StartupItems/": "plists",
    "/System/Library/LaunchDaemons/": "plists",
    "/System/Library/StartupItems/": "plists",
    "/Users/": "user",
    "/boot/": "boot",
    "/etc/cron.d/": "cron",
    "/etc/cron.daily/": "cron",
    "/etc/cron.monthly/": "cron",
    "/etc/cron.weekly/": "cron",
    "/etc/crontab/": "cron",
    "/etc/group": "",
    "/etc/hosts": "",
    "/etc/modules-load": "",
    "/etc/passwd": "",
    "/etc/security/": "",
    "/etc/shadow": "",
    "/etc/systemd/": "conf",
    "/home/": "home",
    "/root/": "root",
    "/private/etc/group": "",
    "/private/etc/hosts": "",
    "/private/etc/modules-load": "",
    "/private/etc/passwd": "",
    "/private/etc/security/": "",
    "/private/etc/shadow": "",
    "/private/etc/systemd": "",
    "/swapfile": "memory",
    # "/tmp/": "tmp",
    "/usr/lib/systemd/user/": "services",
    "/var/cache/cups/": "",
    "/var/at/": "cron",
    "/var/log/": "logs",
    "/var/vm/sleepimage": "memory",
    "/var/vm/swapfile": "memory",
}
quotes = [
    "     Not come the days of the King.\n     May they be blessed.\n",
    "     If my old gaffer could see me now.\n",
    "     I'll have no pointy-ear outscoring me!\n",
    "     I think there is more to this hobbit, than meets the eye.\n",
    "     You are full of surprises Master Baggins.\n",
    "     One ring to rule them all, one ring to find them.\n     One ring to bring them all, and in the darkness bind them.\n",
    "     The world is changed.\n     I feel it in the water.\n     I feel it in the earth.\n     I smell it in the air.\n",
    "     Who knows? Have patience. Go where you must go, and hope!\n",
    "     All we have to decide is what to do with the time that is given us.\n",
    "     Deeds will not be less valiant because they are unpraised.\n",
    "     It is not the strength of the body, but the strength of the spirit.\n",
    "     But in the end it's only a passing thing, this shadow; even darkness must pass.\n",
    "     It's the job that's never started as takes longest to finish.\n",
    "     Coward? Not every man's brave enough to wear a corset!\n",
    "     Bilbo was right. You cannot see what you have become.\n",
    "     He is known in the wild as Strider.\n     His true name, you must discover for yourself.\n",
    "     Legolas said you fought well today. He's grown very fond of you.\n",
    "     You will take NOTHING from me, dwarf.\n     I laid low your warriors of old.\n     I instilled terror in the hearts of men.\n     I AM KING UNDER THE MOUNTAIN!\n",
    "     You've changed, Bilbo Baggins.\n     You're not the same Hobbit as the one who left the Shire...\n",
    "     The world is not in your books and maps. It's out there.\n",
    "     That is private, keep your sticky paws off! It's not ready yet!\n",
    "     I wish you all the luck in the world. I really do.\n",
    "     No. No. You can't turn back now. You're part of the company.\n     You're one of us.\n",
    "     True courage is about knowing not when to take a life, but when to spare one.\n",
    "     The treacherous are ever distrustful.\n",
    "     Let him not vow to walk in the dark, who has not seen the nightfall.\n",
    "     He that breaks a thing to find out what it is has left the path of wisdom.\n",
    "     I was there, Gandalf.\n     I was there three thousand years ago, when Isildur took the ring.\n     I was there the day the strength of Men failed.\n",
    "     I don't know half of you half as well as I should like,\n     and I like less than half of you half as well as you deserve.\n",
    "     Certainty of death. Small chance of success.\n     What are we waiting for?\n",
    "     Do not spoil the wonder with haste!\n",
    "     It came to me, my own, my love... my... preciousssss.\n",
    "     One does not simply walk into Mordor...\n",
    "     Nine companions. So be it. You shall be the fellowship of the ring.\n",
    "     You have my sword. You have my bow; And my axe!\n",
    "     Build me an army, worthy of Mordor!\n",
    "     Nobody tosses a Dwarf!\n",
    "     If in doubt, Meriadoc, always follow your nose.\n",
    "     This is beyond my skill to heal; he needs Elven medicine.\n",
    "     No, thank you! We don't want any more visitors, well-wishers or distant relations!\n",
    "     Mordor! I hope the others find a safer road.\n",
    "     YOU SHALL NOT PASS!\n",
    "     You cannot hide, I see you!\n     There is no life, after me.\n     Only!.. Death!\n",
    "     A wizard is never late, Frodo Baggins.\n     Nor is he early.\n     He arrives precisely when he means to.\n",
    "     Is it secret?! Is it safe?!\n",
    "     Even the smallest person can change the course of the future.\n",
    "     We must move on, we cannot linger.\n",
    "     I wish the ring had never come to me. I wish none of this had happened.\n",
    "     Moonlight drowns out all but the brightest stars.\n",
    "     A hunted man sometimes wearies of distrust and longs for friendship.\n",
    "     The world is indeed full of peril and in it there are many dark places.\n",
    "     Someone else always has to carry on the story.\n",
    "     Your time will come. You will face the same Evil, and you will defeat it.\n",
    "     It is useless to meet revenge with revenge; it will heal nothing.\n",
    "     Despair is only for those who see the end beyond all doubt. We do not.\n",
    "     Anyways, you need people of intelligence on this sort of... mission... quest... thing.\n",
    "     Oh, it's quite simple. If you are a friend, you speak the password, and the doors will open.\n",
    "     The wise speak only of what they know.\n",
    "     Not all those who wander are lost.\n",
    "     It's the deep breath before the plunge.\n",
]
gandalf_root = "/tmp/gandalf"
gandalf_directory = os.path.join(gandalf_root, "gandalf", "acquisitions")
if output_dir != False:
    output_directory = output_dir[0]
else:
    output_directory = gandalf_directory
if mem != False:
    memory = "True"
else:
    memory = "None"
if access_times == True:
    access_times = "True"
else:
    access_times = "None"
if files == True:
    collect_files = "True"
else:
    collect_files = "None"


def overwrite_key(key_name):
    with open(key_name, "wb") as keyfile:
        keyfile.write("YOU SHALL NOT PASS!")
    os.remove(key_name)  # delete key


def generate_filekey():
    key = Fernet.generate_key()
    key_name = "shadowfax.key"
    with open(key_name, "wb") as keyfile:
        keyfile.write(key)
    with open(key_name, "rb") as keyfile:
        filekey = keyfile.read()
    print("     Encryption key 'shadowfax.key' created.\r")
    overwrite_key(key_name)
    return Fernet(filekey), key_name


def generate_cipher():
    pswd = getpass.getpass(
        "    \033[1;30mEnter password to encrypt acquisition archive:\033[1;m "
    ).encode()
    password = bytes(pswd)
    salt = input("    \033[1;30mEnter salt [isengard.pork]:\033[1;m ")
    if salt != "" or salt == "isengard.pork":
        pswdsalt = "isengard.pork"
    else:
        pswdsalt = salt
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=bytes(pswdsalt.encode()),
        iterations=480000,
    )
    key = base64.urlsafe_b64encode(kdf.derive(password))
    cipher = Fernet(key)
    print("     Cipher created successfully\r")
    return cipher


def configure_acquisition(
    encryption_method,
    system_artefacts,
    output_directory,
    memory,
    access_times,
    collect_files,
    encryption_object,
    gandalf_directory,
    gandalf_host,
):
    shutil.copy2("shire/collect_artefacts-py", "tools/acquire_artefacts.py")
    with open("tools/acquire_artefacts.py", "a") as acquire_artefacts:
        acquire_artefacts.write(
            '\n\nacquire_artefacts(\n    "{}",\n    {},\n    "{}",\n    "{}",\n    "{}",\n    "{}",\n    "{}",\n    "{}",\n    "{}",\n)\n'.format(
                encryption_method,
                system_artefacts,
                output_directory,
                memory,
                access_times,
                collect_files,
                encryption_object,
                gandalf_directory,
                gandalf_host,
            )
        )
    os.chmod("tools/acquire_artefacts.py", 0o755)


def main():
    subprocess.Popen(["clear"])
    time.sleep(2)
    starttime = time.time()
    print(
        """
    \n\n
         \033[1;35m____                      .___        .__    _____  
        / ___\ _____     ____    __| _/_____   |  | _/ ____\ 
       / /_/  >\__  \   /    \  / __ | \__  \  |  | \   __\  
       \___  /  / __ \_|   |  \/ /_/ |  / __ \_|  |__|  |    
      /_____/  (____  /|___|  /\____ | (____  /|____/|__|    
                    \/      \/      \/      \/               \n\n{}\033[1;m
    """.format(
            random.choice(quotes)
        )
    )
    if os.path.exists("C:\\TEMP\\gandalf") and acquisition_method.title() == "Local":
        print("      gandalf.py is not designed to run Locally on Windows devices.\n       Please use Invoke-Gandalf.ps1 instead.\n\n")
        sys.exit()
    else:
        pass
    if (
        encryption_method.title() != "Key"
        and encryption_method.title() != "Password"
        and encryption_method.title() != "None"
    ):
        print(
            "     Invalid encryption method - it must be either 'Key', 'Password' or 'None'\n       Please try again.\n\n"
        )
        sys.exit()
    else:
        pass
    if acquisition_method.title() != "Local" and acquisition_method.title() != "Remote":
        print(
            "     Invalid acquisition method - it must be either 'Local' or 'Remote'\n       Please try again.\n\n"
        )
        sys.exit()
    else:
        pass
    if os.path.exists(gandalf_directory):
        shutil.rmtree(gandalf_directory)
    else:
        pass
    try:
        subprocess.Popen(["mkdir", "-p", "{}".format(gandalf_directory)])
    except:
        print(
            "     {} could not be created. Are you running as 'root'?\n       Please try again.\n\n".format(
                gandalf_directory
            )
        )
        sys.exit()
    if encryption_method.title() == "Key":
        encryption_object, key_name = generate_filekey()
        key_confirm = input(
            "    \033[1;30mHave you obtained a copy of the encryption key? Without it, you won't be able to decrypt the acquisition archive!\033[1;m [Y/n] "
        ).encode()
        if key_confirm != "n":
            confirm_key_delete = input(
                "     '{}' will now be deleted. Are you sure?! [Y/n] ".format(key_name)
            )
            if confirm_key_delete != "n":
                overwrite_key(key_name)
            else:
                pass
        else:
            pass
        print()
    elif encryption_method.title() == "Password":
        encryption_object = generate_cipher()
        print()
    else:  # None
        encryption_object = None
    hostlist = []
    hostlist.append(socket.gethostname())
    if acquisition_method == "Local":
        configure_acquisition(
            encryption_method,
            system_artefacts,
            output_directory,
            memory,
            access_times,
            collect_files,
            encryption_object,
            gandalf_directory,
            os.path.join(gandalf_directory, hostlist[0]),
        )
        if memory:
            shutil.copy2(os.path.join("tools", "memory", "avml-main.zip"), "/tmp/gandalf/")
            shutil.copy2(os.path.join("tools", "memory", "osxpmem.app.zip"), "/tmp/gandalf/")
        else:
            pass
        subprocess.Popen(
            ["sudo", "python3", "tools/acquire_artefacts.py"]
        ).communicate()
        if output_directory != gandalf_directory:
            if os.path.exists(
                os.path.join(gandalf_directory, "{}.zip.enc".format(hostlist[0]))
            ):
                shutil.move(
                    os.path.join(gandalf_directory, "{}.zip.enc".format(hostlist[0])),
                    os.path.join(output_directory, "{}.zip.enc".format(hostlist[0])),
                )
            else:
                shutil.move(
                    os.path.join(gandalf_directory, "{}.zip".format(hostlist[0])),
                    os.path.join(output_directory, "{}.zip".format(hostlist[0])),
                )
            shutil.rmtree("/tmp/gandalf/")
        else:
            ext = ""
            if os.path.exists(
                os.path.join(gandalf_directory, "{}.zip.enc".format(hostlist[0]))
            ):
                ext = ".enc"
            else:
                pass
            print(
                "\n    '/tmp/gandalf/' will now be \033[1;31mdeleted\033[1;m. Ensure you have collected '{}/{}.zip{}'".format(
                    gandalf_directory, hostlist[0], ext
                )
            )
            time.sleep(4)
            input("      Collected? [Yes] ")
            shutil.rmtree("/tmp/gandalf/")
    else: # Remote
        if encryption_object == None:
            confirm_encryption = input("     You have chosen to use no encryption when archiving the artefacts. This is not recommended.\n      Are you sure you want to proceed? y/N [N] :")
            if confirm_encryption != "y":
                print("      Please try again with the 'EncryptionObject' parameter set to 'Key' or 'Password'\n\n")
                sys.exit()
            else:
                pass
        else:
            pass
        ssh = paramiko.client.SSHClient()
        with open(os.path.join("lists", "hosts.list")) as host_list:
            for each_host in host_list:
                if not each_host.startswith("#"):
                    hostlist.append(each_host.strip())
                else:
                    pass
        for host in hostlist:
            print("    \033[1;30mConnecting to '{}'...\033[1;m".format(host))
            ssh_ip = input("     \033[1;30mIP address:\033[1;m ")
            ssh_user = input("     \033[1;30m  Username:\033[1;m ")
            ssh_pswd = getpass.getpass("     \033[1;30m  Password:\033[1;m ")
            gandalf_host = os.path.join(gandalf_directory, host)
            configure_acquisition(
                encryption_method,
                system_artefacts,
                output_directory,
                memory,
                access_times,
                collect_files,
                encryption_object,
                gandalf_directory,
                gandalf_host,
            )
            print()
            try:
                ssh.set_missing_host_key_policy(
                    paramiko.AutoAddPolicy()
                )  # initiating connection
                ssh.connect(ssh_ip, username=ssh_user, password=ssh_pswd)
                sshin, sshout, ssherr = ssh.exec_command(
                    "mkdir -p {}".format(gandalf_directory)
                )  # making gandalf directories
                scp = SCPClient(ssh.get_transport())
                if memory:  # sending memory dump tools
                    scp.put(os.path.join("tools", "memory", "avml-main.zip"), "/tmp/gandalf/")
                    scp.put(os.path.join("tools", "memory", "osxpmem.app.zip"), "/tmp/gandalf/")
                else:
                    pass
                scp.put(
                    os.path.join("tools", "acquire_artefacts.py"), "/tmp/gandalf/acquire_artefacts.py"
                )  # sending gandalf acquisition script
                acquire_in, acquire_out, acquire_err = ssh.exec_command(
                    "python3 /tmp/gandalf/acquire_artefacts.py"
                )  # executing gandalf acquisition script
                exec_script = acquire_out.read().decode()
                print(exec_script)
                _, list_out, list_err = ssh.exec_command(
                    "ls /tmp/gandalf/gandalf/acquisitions/"
                )  # listing acquisition archive directory
                dir_listing = str(list_out.read())
                if (
                    "{}.zip.enc".format(gandalf_host.split("/")[-1]) in dir_listing
                ):  # checking for encrypted archive
                    scp.get(
                        "/tmp/gandalf/gandalf/acquisitions/{}.zip.enc".format(
                            gandalf_host.split("/")[-1]
                        ),
                        ".",
                    )
                    print(
                        "     \033[1;30mEncrypted archive collected for '{}'\033[1;m".format(
                            gandalf_host.split("/")[-1]
                        )
                    )
                elif (
                    "{}.zip".format(gandalf_host.split("/")[-1]) in dir_listing
                ):  # checking for unencrypted archive
                    scp.get(
                        "/tmp/gandalf/gandalf/acquisitions/{}.zip".format(
                            gandalf_host.split("/")[-1]
                        ),
                        ".",
                    )
                    print(
                        "     \033[1;30mArchive collected for '{}'\033[1;m".format(
                            gandalf_host.split("/")[-1]
                        )
                    )
                else:
                    print(
                        "     \033[1;30mArchive could not be collected, please try again for '{}'\033[1;m\n".format(
                            gandalf_host.split("/")[-1]
                        )
                    )
                _, rm_out, rm_err = ssh.exec_command(
                    "rm -rf /tmp/gandalf/"
                )  # deleting gandalf
                ssh.close()
            except paramiko.ssh_exception.NoValidConnectionsError:
                print("      \033[1;31mSSH connection to '{}' could not be established.\033[1;m\n".format(host))
            print()
    endtime = time.time()
    diffmins = "{} minutes".format(str(round(((endtime - starttime) - 4) / 60)))
    diffsecs = "{} seconds".format(str(round(((endtime - starttime) - 4) % 60)))
    if int(diffmins.split(" ")[0]) == 1:
        diffmins = diffmins[0:-1]
    else:
        pass
    if int(diffsecs.split(" ")[0]) > 0:
        seconds = "and {}".format(diffsecs)
    else:
        seconds = ""
    print(
        "\n  \033[1;30m-> Finished. Total elapsed time: {} {}\033[1;m\n    ----------------------------------------".format(
            str(diffmins), seconds
        )
    )
    print("      gandalf completed for:")
    for eachhost in hostlist:
        print("       - {}".format(eachhost))
    print("\n\n")


if __name__ == "__main__":
    main()
