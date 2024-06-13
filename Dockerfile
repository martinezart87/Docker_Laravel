ARG PHP_V
FROM php:${PHP_V}-fpm

ARG GIT_CLONE
ARG NODE_VERSION

# Update packages and install basic things
RUN apt-get update && apt-get install -y \
        sudo \
        software-properties-common \
        openssh-client \
        curl \
        ca-certificates \
        wget \
        git \
        zip \
        unzip \
        nano \
        zlib1g-dev \
        libpng-dev \
        libsqlite3-dev \
        sqlite3 \
        libonig-dev \
        libcurl4-openssl-dev \
        libxml2-dev \
        libpq-dev \
        libbz2-dev \
        libzip-dev \
        gnupg gnupg2 gnupg1 \
        cron \
        mc \
        supervisor \
        mlocate

RUN updatedb

COPY crontab /etc/cron.d/app-cron
RUN chmod 0644 /etc/cron.d/app-cron
RUN crontab /etc/cron.d/app-cron
RUN touch /var/log/cron.log
RUN cron

# Install PHP modules
RUN docker-php-ext-install xml
RUN docker-php-ext-install curl
RUN docker-php-ext-install zip
RUN docker-php-ext-install bz2
RUN docker-php-ext-install pdo
RUN docker-php-ext-install gd
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install soap
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install exif

RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pgsql
RUN docker-php-ext-install pdo_pgsql
RUN docker-php-ext-install pdo_sqlite
RUN docker-php-ext-install pdo_mysql

# MSSQL SERVER CONNECTION
#PHP 7.4 - ZMIENIĆ NA pecl install sqlsrv-5.10.1 pdo_sqlsrv-5.10.1
RUN apt-get update && apt-get install -y \
    unixodbc-dev \
    && pecl install sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y \
    msodbcsql17 \
    mssql-tools \
    && rm -rf /var/lib/apt/lists/*

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

ADD ./php/php.ini /usr/local/etc/php/php.ini
ADD ./supervisor/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf
#ADD ./supervisor/laravel-app-start.conf /etc/supervisor/conf.d/laravel-app-start.conf
ADD ./supervisor/laravel-npm-dev.conf /etc/supervisor/conf.d/laravel-npm-dev.conf
ADD ./supervisor/laravel-reverb-start.conf /etc/supervisor/conf.d/laravel-reverb-start.conf
ADD .env /usr/local/bin/init/.env
ADD ./scripts/init.sh /usr/local/bin/init/init.sh

# NODE
RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x -o /tmp/nodesource_setup.sh
RUN bash /tmp/nodesource_setup.sh
RUN apt install nodejs

RUN node -v
RUN npm -v

#NVM
RUN mkdir /usr/local/nvm
ENV NVM_DIR /usr/local/nvm

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && chmod +x $NVM_DIR/nvm.sh

RUN /bin/bash -c "source $NVM_DIR/nvm.sh"

#GIT
COPY .ssh/id_rsa /www-data/.ssh/id_rsa
RUN chmod 600 /www-data/.ssh/id_rsa
RUN ssh-keyscan github.com >> /www-data/.ssh/known_hosts
ENV GIT_SSH_COMMAND="ssh -i /www-data/.ssh/id_rsa -o UserKnownHostsFile=/www-data/.ssh/known_hosts"

CMD ["bash", "-c", "/usr/local/bin/init/init.sh"]