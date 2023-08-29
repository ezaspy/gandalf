#!/usr/bin/env python3 -tt
import base64
import getpass
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC


def generate_cipher():
    pswd = getpass.getpass(
        "    \033[1;30mEnter password to encrypt acquisition archive:\033[1;m "
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
    print("     Cipher created successfully\r")
    return cipher
