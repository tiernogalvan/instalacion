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

## Arreglar GID docker


```bash
wget -qO- https://raw.githubusercontent.com/tiernogalvan/instalacion/main/fix_docker_group.sh | sudo bash
```
