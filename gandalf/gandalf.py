#!/usr/bin/env python3 -tt
import argparse
import getpass
import gnupg
import os
import paramiko
import pyminizip
import random
import shutil
import subprocess
import sys
import time

from shire.collect_artefacts import acquire_artefacts


parser = argparse.ArgumentParser()
parser.add_argument(
    "encryption",
    nargs=1,
    help="Encrpytion Object - Key (recommended), Password or None",
)
parser.add_argument("acquisition", nargs=1, help="Acquisition type - Local or Remote")
# parser.add_argument("output-directory", nargs=1, help="Destination directory of where the collected will be stored")
# parser.add_argument("memory", nargs=1, help="Collect a live memory dump")
# parser.add_argument("show-progress", nargs=1, help="Print progress of individual artefact acquisition to screen")
# parser.add_argument("collect-files", nargs=1, help="Collect files containing string (provided in files.list) in file name")
# parser.add_argument("force", nargs=1, help="Do not unnecessarily prompt")


args = parser.parse_args()
encryption_method = args.encryption
acquisition_method = args.acquisition
# output_dir = args.output_directory
# mem = args.memory
# progress = args.show_progress
# files = args.collect_file
# force = args.force

encryption = encryption_method[0]
acquisition = acquisition_method[0]
# output_directory = output_dir[0]
# memory = mem[0]
# show_progress = progress[0]
# collect_files = files[0]
# no_prompt = force[0]


gandalf_root = "/tmp/gandalf"
gandalf_destination = os.path.join(gandalf_root, "acquisitions")
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
    "/tmp/": "tmp",
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


def obtain_encryption_key():
    subprocess.Popen(
        ["gpg", "--delete-secret-and-public-key", "gandalf@middle.earth", "--yes"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).communicate()
    gpg = gnupg.GPG("/usr/local/bin/gpg")
    gpg.encoding = "utf-8"
    key_input_data = gpg.gen_key_input(
        name_email="gandalf@middle.earth",
        passphrase="shadowfax",
        key_type="RSA",
        key_length="2048",
    )
    gandalf_key = gpg.gen_key(key_input_data)
    # exporting public key
    subprocess.Popen(
        ["gpg", "--export", "gandalf@middle.earth", ">", "gandalf.pub"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).communicate()
    # exporting private key
    subprocess.Popen(
        ["gpg", "--export-secret-key", "gandalf@middle.earth", ">", "gandalf.asc"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).communicate()
    encryption_object = gandalf_key
    return gpg, encryption_object


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
    if (
        encryption.title() != "Key"
        and encryption.title() != "Password"
        and encryption.title() != "None"
    ):
        print(
            "     Invalid encryption method - it must be either 'Key', 'Password' or 'None'\n       Please try again.\n\n"
        )
    else:
        pass
    if acquisition.title() != "Local" and acquisition.title() != "Remote":
        print(
            "     Invalid acquisition method - it must be either 'Local' or 'Remote'\n       Please try again.\n\n"
        )
    else:
        pass
    if os.path.exists(gandalf_destination):
        shutil.rmtree(gandalf_destination)
    else:
        pass
    try:
        os.mkdir(gandalf_root)
    except FileExistsError:
        pass
    os.mkdir(gandalf_destination)
    if encryption.title() == "Key":
        # gpg, encryption_object = obtain_encryption_key()
        if acquisition_method == "Remote":
            k = paramiko.RSAKey.from_private_key_file(encryption_object)
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(hostname="172.16.213.132", username="gandalfthewhite", pkey=k)
            ssh = paramiko.SSHClient()
        else:
            pass
    elif encryption.title() == "Password":
        gpg = None
        if acquisition_method == "Remote":
            try:
                ssh.connect(
                    "172.16.213.132", username="gandalfthewhite", password="shadowfax"
                )
                ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(cmd_to_execute)
            except ssh_exception.NoValidConnectionsError as E:
                print("SSH connection could not be established\n")
        else:
            pass
        encryption_object = gandalf_pswd
    else:  # None
        pass
    # print(encryption_object)
    hostlist = []
    if acquisition == "Local":
        hostlist.append(
            str(
                subprocess.Popen(
                    ["hostname"], stdout=subprocess.PIPE, stderr=subprocess.PIPE
                ).communicate()[0]
            )[2:-3]
        )
    else:
        with open("/tmp/gandalf/gandalf/hosts.list") as host_list:
            hostlist = host_list.readlines()  # make hostlist a list
    for host in hostlist:
        gandalf_host = os.path.join(gandalf_destination, host)
        acquire_artefacts(
            encryption,
            system_artefacts,
            acquisition,
            # output_directory,
            # memory,
            # show_progress,
            # collect_files,
            # no_prompt,
            # encryption_object,
            # gpg,
            # pyminizip,
            gandalf_destination,
            gandalf_host,
        )
    """for directory in os.listdir(gandalf_destination):
        if os.path.isdir(os.path.join(gandalf_destination, directory)):
            shutil.rmtree(os.path.join(gandalf_destination, directory))
        else:
            pass"""
    endtime = time.time()
    diffmins = "{} minutes".format(str(round((endtime - starttime)/60)))
    diffsecs = "{} seconds".format(str(round((endtime - starttime)%60)))
    if int(diffmins.split(" ")[0]) == 1:
        diffmins = diffmins[0:-1]
    else:
        pass
    if int(diffsecs.split(" ")[0]) > 0:
        seconds  = "and {}".format(diffsecs)
    else:
        seconds = ""
    print(
        "\n\n  \033[1;30m-> Finished. Total elapsed time: {} {}\033[1;m\n    ----------------------------------------".format(
            str(diffmins), seconds
        )
    )
    print("      gandalf completed for:")
    for eachhost in hostlist:
        print("       - {}".format(eachhost))
    print("\n\n")


if __name__ == "__main__":
    main()

# https://medium.com/@almirx101/pgp-key-pair-generation-and-encryption-and-decryption-examples-in-python-3-a72f56477c22#id_token=eyJhbGciOiJSUzI1NiIsImtpZCI6IjkxMWUzOWUyNzkyOGFlOWYxZTlkMWUyMTY0NmRlOTJkMTkzNTFiNDQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIyMTYyOTYwMzU4MzQtazFrNnFlMDYwczJ0cDJhMmphbTRsamRjbXMwMHN0dGcuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIyMTYyOTYwMzU4MzQtazFrNnFlMDYwczJ0cDJhMmphbTRsamRjbXMwMHN0dGcuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDM4Mzc1NDM0OTI1Njk4MTkwMjgiLCJlbWFpbCI6ImJlbnNtdGgzOEBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmJmIjoxNjkxNjgxODkyLCJuYW1lIjoiQmVuIFNtaXRoIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hL0FBY0hUdGV4ZnJ6MThpeUtCeGU2UC1sVF85X3BESEFJSW9lVjh6RWdrZWw0YjVsbE9mdz1zOTYtYyIsImdpdmVuX25hbWUiOiJCZW4iLCJmYW1pbHlfbmFtZSI6IlNtaXRoIiwibG9jYWxlIjoiZW4iLCJpYXQiOjE2OTE2ODIxOTIsImV4cCI6MTY5MTY4NTc5MiwianRpIjoiMGViZjgxMzc4MzJlMzE5N2Y5MGRjZjkyNDU5MDY4NzEyZDgyMzVhNSJ9.UhHnIbwCI2RnSXiHqiFcVA2i1JPkWo2B4C6sKCleE46hJTatjy-_SrkA1lcjjSobYed-DV-2WafXGTH4LhG96c-eHxlV84i2FXiVHkSTcyiufOJeO8sFGtx208DBRFpU4Zkha0Nk90uU5dFWxiyO_NgFbq9--CMnSCwNpZ8GlZhXBQh0PaIia_EN1FvNlXD1RWv7deUHh-PDrgbxPAsCQ1Yni75bc6SeSfpwCg1Ul9bwyJ7hzH59gvOnnYWiOljU3ksY4LbjCPXRKV1SQ7ilUN7VoE2v3MN4U_6_cHzAfHUtDCH4bTlZ5SsBrc3__MJM755oZk0ZdOC4wlXhqCjkXg