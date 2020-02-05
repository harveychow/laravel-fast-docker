#########################################
# NPM DEPENDENCIES
#########################################
FROM node:12-alpine as npm-dependencies

WORKDIR /app

COPY package.json package.json
COPY package-lock.json package-lock.json

RUN npm install

#########################################
# COMPOSER DEPENDENCIES + BUILD
#########################################
FROM composer:latest as composer-build

RUN apk update \
    && apk add \
        libxml2-dev \
        php-soap \
    && rm -rf /var/cache/apk/*

RUN docker-php-ext-install \
    bcmath \
    exif \
    soap

WORKDIR /app

RUN composer global require hirak/prestissimo \
    --prefer-dist \
    --prefer-stable \
    --no-progress \
    --no-scripts \
    --no-suggest \
    --no-interaction \
    --ansi

COPY --from=npm-dependencies /app /app

COPY auth.json auth.json
COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install --prefer-dist --no-scripts --no-dev --no-autoloader && rm -rf /root/.composer

COPY . /app

RUN composer dump-autoload --no-scripts --no-dev --optimize

#########################################
# NPM BUILD
#########################################
FROM node:12-alpine as npm-build

WORKDIR /app

COPY --from=composer-build /app /app

RUN npm run prod
RUN npm cache clean --force && rm -rf node_modules

#########################################
# RUN APACHE + PHP
#########################################
FROM php:7.3-apache

RUN rm /etc/apt/preferences.d/no-debian-php \
    && apt-get update \
    && apt-get install -y \
        libxml2-dev \
        php-soap \
    && apt-get clean -y

RUN docker-php-ext-install \
    bcmath \
    exif \
    mbstring \
    opcache \
    pdo_mysql \
    soap

WORKDIR /app
EXPOSE 80

COPY --from=npm-build /app /app
COPY vhost.conf /etc/apache2/sites-available/000-default.conf

RUN chown -R www-data:www-data /app \
    && a2enmod rewrite
