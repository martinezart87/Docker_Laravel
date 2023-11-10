source '.env'
docker compose up -d
mkdir -p /srv/www/${DIR_NAME}
chown -R www-data:www-data /srv/www/${DIR_NAME}
docker exec --user www-data -it ${CONTAINER_NAME_APP} bash
