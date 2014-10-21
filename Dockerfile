FROM ubuntu:14.04
MAINTAINER Egbert Pot <egbert@weboak.nl>

ENV DEBIAN_FRONTEND noninteractive

#update
RUN apt-get update

# Install Supervisor
RUN apt-get install -y supervisor && \
    sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf

# Install PHP
RUN apt-get install -y php5-fpm php5-cli php5-gd php5-mcrypt php5-mysql php5-curl php-pear && \
    sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php5/fpm/pool.d/www.conf && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php5/fpm/php.ini && \
    sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = syslog/' /etc/php5/cli/php.ini

ADD supervisor/php5-fpm.conf /etc/supervisor/conf.d/php5-fpm.conf

# Install Memcached
RUN apt-get install -y php5-memcache memcached

ADD supervisor/memcached.conf /etc/supervisor/conf.d/memcached.conf

# Install Apache2
RUN apt-get install -y curl apache2 libapache2-mod-php5
# RUN apt-get clean

RUN a2enmod rewrite
RUN a2enmod headers
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache
ENV APACHE_RUN_DIR /var/run/apache2

RUN chown -R www-data:www-data /var/www

RUN unlink /etc/apache2/sites-enabled/000-default.conf
ADD apache/000-default.conf /etc/apache2/sites-enabled/000-default.conf

ADD supervisor/apache.conf /etc/supervisor/conf.d/apache.conf

ADD sample_site/index.php /var/www/index.php

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-c", "/etc/supervisor/supervisord.conf"]