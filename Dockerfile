# Use the official PHP image as a base image
FROM php:8.0-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libonig-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensionsR
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create a new Laravel project in a temporary directory
# WORKDIR /var/www_temp
WORKDIR /var/www/public_html
RUN composer create-project --prefer-dist laravel/laravel .
COPY .env /var/www/public_html/.env

# Copy Laravel project to the final directory
# RUN cp -r /var/www_temp/* /var/www/public_html/ && rm -rf /var/www_temp
# Copy Laravel project to the final directory, including hidden files
# RUN mkdir -p /var/www/public_html && shopt -s dotglob && cp -r /var/www_temp/* /var/www/public_html/ && rm -rf /var/www_temp

# Set correct permissions for the application directory
RUN chown -R www-data:www-data /var/www/public_html

# Change current user to www-data
USER www-data

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]