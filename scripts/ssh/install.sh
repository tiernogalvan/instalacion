#!/bin/bash

apt-get install -y openssh-server
install -o root -g root -m 0600 -t /root/.ssh/ -D authorized_keys
install -o root -g root -m 0600 -t /etc/ssh/sshd_config.d/ -D sshd_tierno.conf

# Administrator key
if [[ $(id administrator) ]]; then
  install -o administrator -g administrator -m 0600 -t /home/administrator/.ssh/ -D authorized_keys_administrator authorized_keys
fi

# Por algún motivo es necesario reinstalar en ubuntu 24
apt install --reinstall openssh-server
systemctl enable ssh.service
systemctl restart ssh.service

# UFW debería estar desactivado, pero por si acaso habilitamos ssh
ufw allow ssh
