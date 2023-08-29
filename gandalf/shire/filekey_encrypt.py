#!/usr/bin/env python3 -tt
import os
from cryptography.fernet import Fernet


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
