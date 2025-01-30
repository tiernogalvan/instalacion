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

Se debe ejecutar este script desde un usuario nominal de profesor, pasando el nombre de usuario actual del administrador como parámetro

```bash
wget -qO- https://raw.githubusercontent.com/tiernogalvan/instalacion/main/fix_administrator.sh <nombreErroneo>  | sudo bash
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

