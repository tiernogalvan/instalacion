# Instalación de sistemas

Este repositorio contiene scripts de instalación de ordenadores de alumnos

## Instalación automática

Para instalar ejecuta el siguiente comando:

```bash
wget -qO- https://instalacion.lan.tiernogalvan.es | sudo bash
```

## Instalación manual

Si por fallase el comando anterior, puedes realizar la instalación con estos pasos:

```bash
sudo apt-get install -y git
git clone https://github.com/tiernogalvan/instalacion.git
cd instalacion
sudo bash ./install.sh
```

## Arreglar nombre del usuario administrator

Abrimos la sesión con un usuario que sea sudoer y ejecutamos. El script pedirá que se introduzca el password del nuevo usuario temp, introduce el password deseado

```bash
sudo useradd -s /bin/bash -m temp
sudo usermod -aG sudo temp
sudo passwd temp
```
Cierra sesión y haz login con el usuario temp que se acaba de crear, ejecuta el siguiente script.

```bash
wget -qO- https://raw.githubusercontent.com/tiernogalvan/instalacion/main/fix_administrator.sh | sudo bash
```

Haz logout y vuelve a hacer login con el usuario administrator. Ejecuta este comando


```bash
sudo userdel -r temp
```
