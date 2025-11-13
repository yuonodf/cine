FROM php:7.4-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Install dependencies (skip scripts to avoid artisan errors)
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Create bootstrap/cache directory and set permissions
RUN mkdir -p /var/www/html/bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Clear and regenerate package manifest
RUN rm -f /var/www/html/bootstrap/cache/packages.php \
    && composer dump-autoload --no-interaction \
    && php artisan package:discover --ansi || true

# Configure Apache
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Create startup script to use PORT env var
RUN echo '#!/bin/bash\n\
if [ -n "$PORT" ]; then\n\
  sed -i "s/Listen 80/Listen $PORT/g" /etc/apache2/ports.conf\n\
  sed -i "s/:80>/:$PORT>/g" /etc/apache2/sites-available/*.conf\n\
fi\n\
apache2-foreground' > /start.sh && chmod +x /start.sh

# Expose port
EXPOSE 80

# Start Apache with PORT support
CMD ["/start.sh"]
