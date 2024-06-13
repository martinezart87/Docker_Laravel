#!/bin/bash

echo "Przygotowanie aplikacji..."

if [ -z "$(ls -A /var/www)" ]; then
    source '/usr/local/bin/init/.env'

    sudo rm -rf /var/www/*
    sudo rm -rf /var/www/.*
    cd /var/www && git clone ${GIT_CLONE} .
fi
    
cd /var/www && composer install

echo "Instalacja node..."
cd /var/www && npm install @rollup/rollup-linux-x64-gnu --save-optional
cd /var/www && npm install
sudo chown -R www-data:www-data /var/www

echo "Uruchamianie supervisior..."
sudo service supervisor start
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl reload

echo "Zakończono instalację"

tail -f /dev/null