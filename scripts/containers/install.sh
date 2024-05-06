#!/bin/bash

if [[ ! $(docker volume ls | grep portainer_data) ]]; then
  docker volume create portainer_data
fi
if [[ ! $(docker ps --all | grep portainer) ]]; then
  docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
fi


# MySQL

if [[ ! $(docker ps --all | grep diurno-mysql) ]]; then
  PASSWORD=Sandia4you
  # Este comando lanza un contenedor con MySQL llamado diurno-mysql, la clave de root es Sandia4you
  docker run --name diurno-mysql -e MYSQL_ROOT_PASSWORD=$PASSWORD -p 3306:3306 -d mysql:8.0.0
  docker stop diurno-mysql
fi

if [[ ! $(docker ps --all | grep vespertino-mysql) ]]; then
  PASSWORD=Tokio2324
  # Este comando lanza un contenedor con MySQL llamado vespertino-mysql, la clave de root es Tokio2324
  docker run --name vespertino-mysql -e MYSQL_ROOT_PASSWORD=$PASSWORD -p 3306:3306 -d mysql:8.0.0
  docker stop vespertino-mysql
fi

# PostgreSQL

if [[ ! $(docker ps --all | grep diurno-postgres) ]]; then
  PASSWORD=Sandia4you
  # Este comando lanza un contenedor con Postgresql llamado diurno-postgres, la clave de root es Sandia4you
  docker run --name diurno-postgres -e POSTGRES_PASSWORD=$PASSWORD -p 5432:5432  -d postgres:14.0
  docker stop diurno-postgres
fi

if [[ ! $(docker ps --all | grep vespertino-postgres) ]]; then
  PASSWORD=Tokio2324
  # Este comando lanza un contenedor con Postgresql llamado vespertino-postgres, la clave de root es Tokio2324
  docker run --name vespertino-postgres -e POSTGRES_PASSWORD=$PASSWORD -p 5432:5432  -d postgres:14.0
  docker stop vespertino-postgres
fi

# Xampp

if [[ ! $(docker ps --all | grep diurno-xampp) ]]; then
  mkdir -p /home/diurno/xampp
  chown diurno:diurno /home/diurno/xampp
  chmod 777 -R /home/diurno/xampp
  docker run --name diurno-xampp -p 41061:22 -p 41062:80 -d -v /home/diurno/xampp:/www tomsik68/xampp:8
  docker stop diurno-xampp
fi

if [[ ! $(docker ps --all | grep vespertino-xampp) ]]; then
  mkdir -p /home/vespertino/xampp
  chown vespertino:vespertino /home/vespertino/xampp
  chmod 777 -R /home/vespertino/xampp
  docker run --name vespertino-xampp -p 41061:22 -p 41062:80 -d -v /home/vespertino/xampp:/www tomsik68/xampp:8
  docker stop vespertino-xampp
fi

