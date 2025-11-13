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
RUN php -r "\
\$file = '/var/www/html/vendor/laravel/framework/src/Illuminate/Foundation/PackageManifest.php';\
\$content = file_get_contents(\$file);\
\$content = str_replace(\
    'if (\$this->files->exists(\$path = \$this->vendorPath.\'/composer/installed.json\')) {' . PHP_EOL . '            \$packages = json_decode(\$this->files->get(\$path), true);' . PHP_EOL . '        }',\
    'if (\$this->files->exists(\$path = \$this->vendorPath.\'/composer/installed.json\')) {' . PHP_EOL . '            \$packages = json_decode(\$this->files->get(\$path), true);' . PHP_EOL . '            if (is_array(\$packages) && isset(\$packages[0]) && is_array(\$packages[0]) && isset(\$packages[0][0]) && is_array(\$packages[0][0])) {' . PHP_EOL . '                \$packages = \$packages[0];' . PHP_EOL . '            } elseif (is_array(\$packages) && isset(\$packages[\"packages\"]) && is_array(\$packages[\"packages\"])) {' . PHP_EOL . '                \$packages = \$packages[\"packages\"];' . PHP_EOL . '            }' . PHP_EOL . '        }',\
    \$content\
);\
\$content = str_replace(\
    'return [\$this->format(\$package[\'name\']) => \$package[\'extra\'][\'laravel\'] ?? []];',\
    'if (!is_array(\$package) || !isset(\$package[\'name\'])) { return []; } return [\$this->format(\$package[\'name\']) => \$package[\'extra\'][\'laravel\'] ?? []];',\
    \$content\
);\
file_put_contents(\$file, \$content);\
"

# Clear and regenerate package manifest
RUN rm -f /var/www/html/bootstrap/cache/packages.php \
    && composer dump-autoload --no-interaction \
    && php artisan clear-compiled || true \
    && php artisan package:discover --ansi || true

# Configure Apache
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Create startup script to use PORT env var and fix packages.php
RUN echo '#!/bin/bash\n\
# Always regenerate packages.php on startup to avoid corruption issues\n\
cd /var/www/html\n\
rm -f bootstrap/cache/packages.php\n\
# Fix installed.json if it has wrong structure (nested arrays)\n\
if [ -f vendor/composer/installed.json ]; then\n\
  php -r "\n\
    \$json = file_get_contents(\"vendor/composer/installed.json\");\n\
    \$data = json_decode(\$json, true);\n\
    if (is_array(\$data) && isset(\$data[0]) && is_array(\$data[0]) && isset(\$data[0][0])) {\n\
      // If first element is array of arrays, flatten it\n\
      \$data = \$data[0];\n\
    }\n\
    file_put_contents(\"vendor/composer/installed.json\", json_encode(\$data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));\n\
  " 2>/dev/null || true\n\
fi\n\
# Try to discover packages, if it fails create empty packages.php\n\
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
