# Instalación de sistemas

Este repositorio contiene scripts de instalación de ordenadores de alumnos

## install.sh

Ejecuta los siguientes comandos

```bash
wget https://raw.githubusercontent.com/tiernogalvan/instalacion/main/install.sh
wget https://raw.githubusercontent.com/tiernogalvan/instalacion/main/01proxy.conf
sudo mv 01proxy.conf /etc/apt/apt.conf.d/
chmod +x install.sh
sudo ./install.sh
rm install.sh
```
