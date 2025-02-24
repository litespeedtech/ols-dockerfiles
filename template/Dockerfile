FROM ubuntu:24.04

ARG OLS_VERSION
ARG PHP_VERSION
ARG TARGETPLATFORM

RUN apt-get update && apt-get install wget curl cron tzdata -y

RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        wget https://openlitespeed.org/packages/openlitespeed-$OLS_VERSION-x86_64-linux.tgz && \
        tar xzf openlitespeed-$OLS_VERSION-x86_64-linux.tgz && cd openlitespeed && ./install.sh && \
        echo 'cloud-docker' > /usr/local/lsws/PLAT && rm -rf /openlitespeed && rm /openlitespeed-$OLS_VERSION-x86_64-linux.tgz; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        wget https://openlitespeed.org/packages/openlitespeed-$OLS_VERSION-aarch64-linux.tgz && \
        tar xzf openlitespeed-$OLS_VERSION-aarch64-linux.tgz && cd openlitespeed && ./install.sh && \
        echo 'cloud-docker' > /usr/local/lsws/PLAT && rm -rf /openlitespeed && rm /openlitespeed-$OLS_VERSION-aarch64-linux.tgz; \
    else \
        echo "$TARGETPLATFORM is not supported"; \
    fi

RUN wget -O - https://repo.litespeed.sh | bash

RUN apt-get install mysql-client $PHP_VERSION $PHP_VERSION-common $PHP_VERSION-mysql $PHP_VERSION-opcache \
    $PHP_VERSION-curl $PHP_VERSION-imagick $PHP_VERSION-redis $PHP_VERSION-memcached $PHP_VERSION-intl -y

RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp7* ]]; then apt-get install $PHP_VERSION-json -y; fi"]

RUN wget -O /usr/local/lsws/admin/misc/lsup.sh \
    https://raw.githubusercontent.com/litespeedtech/openlitespeed/master/dist/admin/misc/lsup.sh && \
    chmod +x /usr/local/lsws/admin/misc/lsup.sh

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp && \
	ln -s /usr/local/lsws/$PHP_VERSION/bin/php /usr/bin/php

RUN wget -O -  https://get.acme.sh | sh

EXPOSE 7080
ENV PATH="/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin"

ADD docker.conf /usr/local/lsws/conf/templates/docker.conf
ADD setup_docker.sh /usr/local/lsws/bin/setup_docker.sh
ADD htpasswd /usr/local/lsws/admin/conf/htpasswd
ADD phpini_update.sh /opt/phpini_update.sh

RUN /usr/local/lsws/bin/setup_docker.sh && rm /usr/local/lsws/bin/setup_docker.sh
RUN chown 994:994 /usr/local/lsws/conf -R
RUN cp -RP /usr/local/lsws/conf/ /usr/local/lsws/.conf/
RUN cp -RP /usr/local/lsws/admin/conf /usr/local/lsws/admin/.conf/
#RUN sed -i "s|fcgi-bin/lsphp|/usr/local/lsws/$PHP_VERSION/bin/lsphp|g" /usr/local/lsws/conf/httpd_config.conf
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp8* ]]; then ln -sf /usr/local/lsws/$PHP_VERSION/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp8; fi"]
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp8* ]]; then ln -sf /usr/local/lsws/fcgi-bin/lsphp8 /usr/local/lsws/fcgi-bin/lsphp; fi"]
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp7* ]]; then ln -sf /usr/local/lsws/$PHP_VERSION/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp7; fi"]
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp7* ]]; then ln -sf /usr/local/lsws/fcgi-bin/lsphp7 /usr/local/lsws/fcgi-bin/lsphp; fi"]
RUN /opt/phpini_update.sh && rm /opt/phpini_update.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /var/www/vhosts/
