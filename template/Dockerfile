#FROM debian:jessie-slim
FROM ubuntu:18.04

ARG OLS_VERSION
ARG PHP_VERSION


RUN apt-get update && apt-get install wget curl cron tzdata -y

RUN wget https://openlitespeed.org/preuse/openlitespeed-$OLS_VERSION.tgz && \
    tar xzvf openlitespeed-$OLS_VERSION.tgz && cd openlitespeed && ./install.sh && rm -rf /openlitespeed

RUN apt-get install mysql-client $PHP_VERSION $PHP_VERSION-common $PHP_VERSION-mysql $PHP_VERSION-opcache \
    $PHP_VERSION-curl $PHP_VERSION-json $PHP_VERSION-imagick $PHP_VERSION-redis $PHP_VERSION-memcached $PHP_VERSION-intl -y

RUN wget -O /usr/local/lsws/admin/misc/lsup.sh \
    https://raw.githubusercontent.com/litespeedtech/openlitespeed/master/dist/admin/misc/lsup.sh && \
    chmod +x /usr/local/lsws/admin/misc/lsup.sh

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp && \
	ln -s /usr/local/lsws/$PHP_VERSION/bin/lsphp /usr/bin/php

RUN wget -O -  https://get.acme.sh | sh

EXPOSE 7080

ADD docker.conf /usr/local/lsws/conf/templates/docker.conf
ADD httpd_config.sh /usr/local/lsws/bin/httpd_config.sh
add httpd_config.xml /usr/local/lsws/conf/httpd_config.xml
add htpasswd /usr/local/lsws/admin/conf/htpasswd
RUN /usr/local/lsws/bin/httpd_config.sh && rm /usr/local/lsws/bin/httpd_config.sh
RUN chown 999:999 /usr/local/lsws/conf -R
RUN cp -RP /usr/local/lsws/conf/ /usr/local/lsws/.conf/
RUN cp -RP /usr/local/lsws/admin/conf /usr/local/lsws/admin/.conf/
RUN ln -sf /usr/local/lsws/$PHP_VERSION/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp7
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /var/www/vhosts/
CMD ["/usr/local/lsws/bin/lswsctrl","start"]
