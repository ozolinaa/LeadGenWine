#!/bin/bash

# set permissions  | chmod +x docker_compose_update_leadgenweb.sh |  chmod +x /opt/leadgen/docker_compose_update_leadgenweb.sh
# run once        | sudo ./docker_compose_update_leadgenweb.sh | sudo /opt/leadgen/docker_compose_update_leadgenweb.sh

# Default values of arguments
TAG="latest"

# Loop through arguments and process them
for arg in "$@"
do
    case $arg in
        -t|--tag)
        TAG="$2"
        shift # Remove argument name from processing
        shift # Remove argument value from processing
        ;;
    esac
done


# BACKUP
echo "Starting leadgen update to $TAG ..."

cd /opt/leadgen
sed -i "s/leadgenweb:latest/leadgenweb:$TAG/g" docker-compose.yml
docker-compose pull leadgen_web
# aa-remove-unknown
docker-compose up -d --no-deps --build leadgen_web
docker rmi $(docker images -a -q)

sed -i "s/leadgenweb:$TAG/leadgenweb:latest/g" docker-compose.yml

echo "Finished leadgen update"
