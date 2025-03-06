FROM ubuntu:24.04
ARG OLS_VERSION
ARG PHP_VERSION
ARG TARGETPLATFORM

ENV LS_FD='/usr/local/lsws'
ENV PHPINI_PATH="$LS_FD/$PHP_VERSION/etc/php/*/litespeed/php.ini"

RUN apt-get update && apt-get install wget curl cron tzdata -y

RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        wget https://openlitespeed.org/packages/openlitespeed-$OLS_VERSION-x86_64-linux.tgz && \
        tar xzf openlitespeed-$OLS_VERSION-x86_64-linux.tgz && cd openlitespeed && ./install.sh && \
        echo 'cloud-docker' > $LS_FD/PLAT && rm -rf /openlitespeed && rm /openlitespeed-$OLS_VERSION-x86_64-linux.tgz; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        wget https://openlitespeed.org/packages/openlitespeed-$OLS_VERSION-aarch64-linux.tgz && \
        tar xzf openlitespeed-$OLS_VERSION-aarch64-linux.tgz && cd openlitespeed && ./install.sh && \
        echo 'cloud-docker' > $LS_FD/PLAT && rm -rf /openlitespeed && rm /openlitespeed-$OLS_VERSION-aarch64-linux.tgz; \
    else \
        echo "$TARGETPLATFORM is not supported"; \
    fi

RUN wget -O - https://repo.litespeed.sh | bash

RUN apt-get install mysql-client $PHP_VERSION $PHP_VERSION-common $PHP_VERSION-mysql $PHP_VERSION-opcache \
    $PHP_VERSION-curl $PHP_VERSION-imagick $PHP_VERSION-redis $PHP_VERSION-memcached $PHP_VERSION-intl -y

RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp7* ]]; then apt-get install $PHP_VERSION-json -y; fi"]

RUN wget -O $LS_FD/admin/misc/lsup.sh \
    https://raw.githubusercontent.com/litespeedtech/openlitespeed/master/dist/admin/misc/lsup.sh && \
    chmod +x $LS_FD/admin/misc/lsup.sh

RUN sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' $PHPINI_PATH && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1024M/g' $PHPINI_PATH && \
    sed -i 's/post_max_size = 8M/post_max_size = 1024M/g' $PHPINI_PATH && \
    sed -i 's/max_execution_time = 30/max_execution_time = 300/g' $PHPINI_PATH

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp && \
	ln -s $LS_FD/$PHP_VERSION/bin/php /usr/bin/php

RUN wget -O -  https://get.acme.sh | sh

EXPOSE 7080
ENV PATH="/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin"

ADD docker.conf $LS_FD/conf/templates/docker.conf
ADD setup_docker.sh $LS_FD/bin/setup_docker.sh
ADD htpasswd $LS_FD/admin/conf/htpasswd

RUN $LS_FD/bin/setup_docker.sh && rm $LS_FD/bin/setup_docker.sh
RUN chown 994:994 $LS_FD/conf -R
RUN cp -RP $LS_FD/conf/ $LS_FD/.conf/
RUN cp -RP $LS_FD/admin/conf $LS_FD/admin/.conf/
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp8* ]]; then ln -sf $LS_FD/$PHP_VERSION/bin/lsphp $LS_FD/fcgi-bin/lsphp8; fi"]
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp8* ]]; then ln -sf $LS_FD/fcgi-bin/lsphp8 $LS_FD/fcgi-bin/lsphp; fi"]
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp7* ]]; then ln -sf $LS_FD/$PHP_VERSION/bin/lsphp $LS_FD/fcgi-bin/lsphp7; fi"]
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp7* ]]; then ln -sf $LS_FD/fcgi-bin/lsphp7 $LS_FD/fcgi-bin/lsphp; fi"]
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /var/www/vhosts/
