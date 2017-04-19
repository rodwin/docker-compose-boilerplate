FROM php:5.6-apache

MAINTAINER rodwin lising <rodwinlising@gmail.com>

# install the PHP extensions we need
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libtidy-dev \
        git nano \
    && docker-php-ext-install -j$(nproc) iconv mcrypt mbstring zip mysqli pdo_mysql tidy bcmath\
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

#install nodejs
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash && apt-get install nodejs

# Install Composer
RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && echo "alias composer='/usr/local/bin/composer.phar'" >> ~/.bashrc

# Source the bash
RUN . ~/.bashrc

RUN a2enmod rewrite

ADD config/php.ini /usr/local/etc/php/
ADD config/000-laravel.conf /etc/apache2/sites-available/
RUN /usr/sbin/a2dissite '*' && /usr/sbin/a2ensite 000-laravel && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# COPY src/ /var/www/html/
# Volume configuration
VOLUME ["/var/www/html"]