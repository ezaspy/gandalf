#!/usr/bin/env python3 -tt
import base64
import getpass
import os
import random
import subprocess
import sys
import time
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC


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


def generate_passkey():
    pswd = getpass.getpass(
        "    \033[1;30mEnter password to decrypt acquisition archive:\033[1;m "
    ).encode()
    password = bytes(pswd)
    salt = input(
        "    \033[1;30mEnter salt [isengard.pork]:\033[1;m "
    )
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
    return cipher


def main():
    subprocess.Popen(["clear"])
    time.sleep(2)
    print(
        """
    \n\n
         \033[1;35m____                      .___        .__    _____  
        / ___\ _____     ____    __| _/\033[4mECRYPT\033[0;m\033[1;35m  |  | _/ ____\ 
       / /_/  >\__  \   /    \  / __ | \__  \  |  | \   __\  
       \___  /  / __ \_|   |  \/ /_/ |  / __ \_|  |__|  |    
      /_____/  (____  /|___|  /\____ | (____  /|____/|__|    
                    \/      \/      \/      \/               \n\n{}\033[1;m
    """.format(
            random.choice(quotes)
        )
    )
    encrypted_archive = input(
        "    Provide location of encrypted archive: "
    )
    print()
    if not encrypted_archive.endswith(".zip.enc"):
        print("    {} must end with '.zip.enc', please try again.\n\n".format(encrypted_archive))
        sys.exit()
    elif not os.path.exists(encrypted_archive):
        print("    {} does not exist, please try again.\n\n".format(encrypted_archive))
        sys.exit()
    elif not os.path.isfile(encrypted_archive):
        print("    {} is not of file 'type', please try again.\n\n".format(encrypted_archive))
        sys.exit()
    else:
        cipher = generate_passkey()
        with open(encrypted_archive, "rb") as enc_archive:
            encrypted_content = enc_archive.read()
        decrypted_content = cipher.decrypt(encrypted_content)
        with open("{}.dec.zip".format(encrypted_archive[0:-8]), "wb") as dec_archive:
            dec_archive.write(decrypted_content)
        print("\n    Successfully decrypted \033[1;30m{}\033[1;m\n                        to \033[1;32m{}.dec.zip\033[1;m\n\n".format(encrypted_archive, encrypted_archive[0:-8]))


if __name__ == "__main__":
    main()
