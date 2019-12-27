#!/bin/bash

# set permissions  | chmod +x docker_compose_update_leadgenweb.sh |  chmod +x /opt/leadgen/docker_compose_update_leadgenweb.sh
# run once        | sudo ./docker_compose_update_leadgenweb.sh | sudo /opt/leadgen/docker_compose_update_leadgenweb.sh

# BACKUP
echo "Starting leadgen update..."

cd /opt/leadgen
docker-compose pull web_app
aa-remove-unknown
docker-compose up -d --no-deps --build web_app
docker rmi $(docker images -a -q)

echo "Finished leadgen update"
