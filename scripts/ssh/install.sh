#!/bin/bash

apt-get install -y openssh-server
install -o root -g root -m 0600 -D authorized_keys /root/.ssh/
install -o root -g root -m 0600 -D sshd_tierno.conf /etc/ssh/sshd_config.d/
systemctl restart sshd.service
