# Instalación de sistemas

Este repositorio contiene scripts de instalación de ordenadores de alumnos

## Instalación automática

Para instalar ejecuta el siguiente comando:

```bash
wget -qO- https://instalacion.lan.tiernogalvan.es | sudo bash
```


## Instalación manual

Si por algún motivo fallase el servidor `instalacion.lan.tiernogalvan.es`, puedes realizar los siguientes pasos:

```
$ sudo apt-get install -y git
$ git clone https://github.com/tiernogalvan/instalacion.git
$ cd instalacion
$ sudo bash ./install.sh
```
