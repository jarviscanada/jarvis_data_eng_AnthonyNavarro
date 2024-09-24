#!/bin/bash

# Capture CLI arguments
cmd=$1
db_username=$2
db_password=$3

# Start Docker if not running
sudo systemctl status docker || sudo systemctl start docker

# Check if the container exists
docker container inspect jrvs-psql > /dev/null 2>&1
container_status=$?

# Use switch case to handle create|start|stop options
case $cmd in
  create)
    # Check if the container is already created
    if [ $container_status -eq 0 ]; then
      echo "Error: Container 'jrvs-psql' already exists."
      exit 1
    fi

    # Check number of CLI arguments (must be 3 for create)
    if [ $# -ne 3 ]; then
      echo "Error: 'create' command requires username and password."
      echo "Usage: ./psql_docker.sh create [db_username] [db_password]"
      exit 1
    fi

    # Create Docker volume for persistent data
    docker volume create pgdata

    # Create and run the PostgreSQL container
    docker run --name jrvs-psql -e POSTGRES_USER=$db_username -e POSTGRES_PASSWORD=$db_password \
    -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres:9.6-alpine
    
    # Exit with the status code of the last command
    exit $?
    ;;

  start)
    # Check if the container exists before trying to start it
    if [ $container_status -ne 0 ]; then
      echo "Error: Container 'jrvs-psql' has not been created."
      exit 1
    fi

    # Start the container
    docker container start jrvs-psql
    exit $?
    ;;

  stop)
    # Check if the container exists before trying to stop it
    if [ $container_status -ne 0 ]; then
      echo "Error: Container 'jrvs-psql' has not been created."
      exit 1
    fi

    # Stop the container
    docker container stop jrvs-psql
    exit $?
    ;;

  *)
    echo "Error: Invalid command."
    echo "Usage: ./psql_docker.sh start|stop|create [db_username] [db_password]"
    exit 1
    ;;
esac

