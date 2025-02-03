#!/bin/bash
#
# This script should be run in a fresh installation of Ubuntu 22.04
#

BAD_NAME=$(cat /etc/passwd | grep :1000:1000: | awk -F : '{ print $1 }')

echo "Se va a renombrar el usuario ${BAD_NAME} a administrator"

groupadd administrator
sss_cache -u administrator
sss_cache -E

usermod -g administrator -l administrator ${BAD_NAME}
