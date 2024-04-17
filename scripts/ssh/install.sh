#!/bin/bash

apt-get install -y openssh-server
install -o root -g root -m 0600 -t /root/.ssh/ -D authorized_keys
install -o root -g root -m 0600 -t /etc/ssh/sshd_config.d/ -D sshd_tierno.conf
systemctl restart sshd.service
