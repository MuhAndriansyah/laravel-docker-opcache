ARG ALPINE_VERSION=3.17
FROM alpine:${ALPINE_VERSION}

LABEL Maintainer="Tim de Pater <code@trafex.nl>"
LABEL Description="Lightweight container with Nginx 1.22 & PHP 8.1 based on Alpine Linux."

# Install packages and remove default server definition
RUN apk add --no-cache \
  curl \
  nginx \
  php81 \
  php81-ctype \
  php81-curl \
  php81-dom \
  php81-fpm \
  php81-gd \
  php81-intl \
  php81-pdo_mysql \
  php81-pdo_sqlite \
  php81-mbstring \
  php81-mysqli \
  php81-opcache \
  php81-openssl \
  php81-phar \
  php81-session \
  php81-xmlwriter \
  php81-fileinfo \
  php81-xml \
  php81-xmlreader \
  php81-tokenizer \
  supervisor

# Setup document root
RUN mkdir -p /var/www/html

# Configure nginx
COPY docker/config/nginx.conf /etc/nginx/nginx.conf

# Configure nginx - default server
COPY docker/config/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
COPY docker/config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
COPY docker/config/php.ini /etc/php81/conf.d/custom.ini

# Configure supervisord
COPY docker/config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html && \
    chown -R nobody.nobody /run && \
    chown -R nobody.nobody /var/lib/nginx && \
    chown -R nobody.nobody /var/log/nginx

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /var/www/html

# Copy App to Workdir
COPY --chown=nobody src/ /var/www/html/

#Configure docker-entrypoint
COPY --chown=nobody docker/docker-entrypoint.sh /var/www/html/docker/
RUN chmod +x /var/www/html/docker/docker-entrypoint.sh

# Install composer from the official image
COPY --from=composer:2.5.4 /usr/bin/composer /usr/bin/composer


# Set ENV CONTAINER_ROLE
ARG CONTAINER_ROLE
ENV CONTAINER_ROLE $DOCKER_APP

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
ENTRYPOINT [ "docker/docker-entrypoint.sh" ]