#!/bin/bash

# MySQL

function create_mysql() {
  container_name="$1"
  password="$2"
  if [[ ! $(docker ps --all | grep $container_name) ]]; then
    # Este comando lanza un contenedor con MySQL llamado diurno-mysql, la clave de root es Sandia4you
    # docker run --name diurno-mysql -e MYSQL_ROOT_PASSWORD=$password -p 3306:3306 -d mysql:8.0.0

    # MySQL 8.0 ignora los CHECK al crear tablas
    # MySQL 8.1 ya no soporta passwords normales por defecto, hay que pasarle el parámetro siguiente.
    docker run --name $container_name -e MYSQL_ROOT_PASSWORD=$password -p 3306:3306 -d mysql:8.1 mysqld --default-authentication-plugin=mysql_native_password
    docker stop $container_name
  fi
}

create_mysql diurno-mysql Sandia4you
create_mysql vespertino-mysql Tokio2324

# PostgreSQL

function create_postgress() {
  container_name="$1"
  password="$2"
  if [[ ! $(docker ps --all | grep $container_name) ]]; then
    docker run --name $container_name -e POSTGRES_PASSWORD=$password -p 5432:5432  -d postgres:14.0
    docker stop $container_name
  fi
}

create_postgress diurno-postgres Sandia4you
create_postgress vespertino-postgres Tokio2324
