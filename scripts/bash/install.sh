#!/bin/bash

install -o root -g root -m 0644 -t /etc/skel/ -D .bashrc
install -o root -g root -m 0644 -t /etc/skel/ -D .gitconfig
install -o root -g root -m 0644 -t /etc/profile.d/ -D default-umask.sh
