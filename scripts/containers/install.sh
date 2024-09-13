#!/bin/bash

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

