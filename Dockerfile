FROM debian:buster-slim
ENV COMPOSER_ALLOW_SUPERUSER 1

ADD sources.list /etc/apt/sources.list
RUN apt update && \
  apt -y --no-install-recommends install \
  cron zip zlibc apache2 libapache2-mod-php \
  php7.0 php-mbstring php-gd php-curl php-dom php-zip php-ldap php-mongodb && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

WORKDIR /var/www/actionview
ADD . /var/www/actionview/
RUN \
  ./composer.phar config repo.packagist composer https://mirrors.aliyun.com/composer/ && \
  ./composer.phar install --no-dev --no-cache

RUN /bin/bash config.sh
ADD docker/web/conf/000-default.conf /etc/apache2/sites-available/000-default.conf
ADD docker/web/conf/crontabfile /var/www/actionview/crontabfile
ADD docker/web/scripts /scripts
RUN chmod a+x /scripts/*.sh
VOLUME ["/var/www/actionview/storage", "/var/log/apache2"]
CMD ["/scripts/run.sh"]
