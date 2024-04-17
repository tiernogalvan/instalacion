#!/bin/bash

apt-get install -y openssh-server
install -o root -g root -m 0400 -d /root/.ssh/ authorized_keys
echo 'PermitRootLogin prohibit-password' >> /etc/ssh/sshd_config
echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
echo 'PermitEmptyPasswords no' >> /etc/ssh/sshd_config

