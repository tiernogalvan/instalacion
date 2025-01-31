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
sudo adduser -s /bin/bash -m temp
sudo usermod -aG sudo temp
sudo passwd temp
```
Cierra sesión y haz login con el usuario temp que se acaba de crear, ejecuta el siguiente script pasando como parámetro el nombre del usuario de instalación actual.

```bash
wget -qO- https://raw.githubusercontent.com/tiernogalvan/instalacion/main/fix_administrator.sh <nombreErroneo>  | sudo bash
```

Haz logout y vuelve a hacer login con el usuario administrator. Ejecuta este comando


```bash
sudo userdel -r temp
```

## Arreglar permisos de Docker (TODO eliminar cuando se haya solucionado la B23)

Script para arreglar permisos de Docker. Este problema sólo debería ocurrir en las instalaciones de la B23 y B27

```bash
wget -qO- https://raw.githubusercontent.com/tiernogalvan/instalacion/main/fix_docker.sh | sudo bash
```

## Creación de usuario local para estudiantes

Script para crear un usuario local en los ordenadores de los estudiantes en caso de que haya algún problema con LDAP

```bash
wget -qO- https://raw.githubusercontent.com/tiernogalvan/instalacion/main/scripts/local_user/install.sh | sudo bash
```

Si se desea eliminar el usuario estudiante ejecutar

```bash
wget -qO- https://raw.githubusercontent.com/tiernogalvan/instalacion/main/scripts/local_user/remove.sh | sudo bash
```

