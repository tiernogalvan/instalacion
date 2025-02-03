#!/bin/bash
#
# This script should be run in a fresh installation of Ubuntu 22.04
#


echo "Se va a renombrar el usuario $1 a administrator"

groupadd administrator
sss_cache -u administrator
sss_cache -E

usermod -g administrator -l administrator $1
