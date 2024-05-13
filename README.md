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

## Arreglar permisos de Docker (TODO eliminar cuando se haya solucionado la B23)

Script para arreglar permisos de Docker. Este problema sólo debería ocurrir en las instalaciones de la B23 y B27

```bash
wget -qO- https://github.com/tiernogalvan/instalacion/fix_docker.sh | sudo bash
```