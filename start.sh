#!/bin/bash

source '.env'
sudo rm -rf /var/www/${APP_NAME}
mkdir -p /srv/www/${APP_NAME}
docker compose up -d
chown -R www-data:www-data /srv/www/${APP_NAME}
docker exec --user www-data -it ${APP_NAME} bash
