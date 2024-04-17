#!/bin/bash
#
# This script should be run in a fresh installation of Ubuntu 22.04
#

mv 01proxy.conf /etc/apt/apt.conf.d/
apt-get update
apt-get upgrade -y
apt-get install -y ca-certificates curl wget gnupg git git-gui rar net-tools openssl vim neovim ranger
apt-get remove -y aisleriot gnome-mahjongg gnome-mines gnome-sudoku thunderbird
apt-get autoremove -y
apt-get autoclean -y

