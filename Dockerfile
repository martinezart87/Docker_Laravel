FROM php:8.2.5-fpm

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
	cron

# Copy hello-cron file to the cron.d directory
COPY crontab /etc/cron.d/app-cron
# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/app-cron
# Apply cron job
RUN crontab /etc/cron.d/app-cron
# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
# CMD cron && tail -f /var/log/cron.log

# Install PHP modules
RUN docker-php-ext-install zip
RUN docker-php-ext-install pdo_sqlite
RUN docker-php-ext-install bz2
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install pdo_pgsql
RUN docker-php-ext-install pgsql
RUN docker-php-ext-install gd
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install curl
RUN docker-php-ext-install xml
RUN docker-php-ext-install soap
RUN docker-php-ext-install bcmath

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

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
