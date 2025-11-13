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
# Use --no-scripts to prevent artisan from running before setup is complete
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts \
    && composer dump-autoload --no-interaction

# Create bootstrap/cache directory and set permissions
RUN mkdir -p /var/www/html/bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Patch PackageManifest to handle nested array structure
RUN php patch-package-manifest.php || true

# Create empty packages.php to bypass PackageManifest errors
RUN echo '<?php return [];' > /var/www/html/bootstrap/cache/packages.php

# Try to regenerate package manifest, but don't fail if it errors
RUN composer dump-autoload --no-interaction \
    && php artisan clear-compiled || true \
    && php artisan package:discover --ansi 2>&1 | head -20 || echo '<?php return [];' > /var/www/html/bootstrap/cache/packages.php

# Configure Apache
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Create startup script to use PORT env var and fix packages.php
RUN echo '#!/bin/bash\n\
cd /var/www/html\n\
# Always create empty packages.php first to prevent PackageManifest errors\n\
echo "<?php return [];" > bootstrap/cache/packages.php\n\
# Try to patch PackageManifest if patch script exists\n\
php patch-package-manifest.php 2>/dev/null || true\n\
# Try to discover packages, but always fallback to empty array\n\
php artisan package:discover --ansi 2>/dev/null || echo "<?php return [];" > bootstrap/cache/packages.php\n\
if [ -n "$PORT" ]; then\n\
  sed -i "s/Listen 80/Listen $PORT/g" /etc/apache2/ports.conf\n\
  sed -i "s/:80>/:$PORT>/g" /etc/apache2/sites-available/*.conf\n\
fi\n\
apache2-foreground' > /start.sh && chmod +x /start.sh

# Expose port
EXPOSE 80

# Start Apache with PORT support
CMD ["/start.sh"]
