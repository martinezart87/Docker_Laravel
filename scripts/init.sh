#!/bin/bash

source '/usr/local/bin/init/.env'

echo "Przygotowanie aplikacji..."
sudo rm -rf /var/www/*
sudo rm -rf /var/www/.*
cd /var/www && git clone ${GIT_CLONE} .
cd /var/www && composer install

echo "Instalacja node..."
cd /var/www && npm install
sudo chown -R www-data:www-data /var/www

echo "Uruchamianie supervisior..."
sudo service supervisor start
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl reload

echo "Zakończono instalację"

tail -f /dev/null