ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}
ARG OLS_VERSION
ARG PHP_VERSION
ARG TARGETPLATFORM

ENV LS_FD='/usr/local/lsws'
ENV PHPINI_PATH="$LS_FD/$PHP_VERSION/etc/php/*/litespeed/php.ini"

# Install base dependencies
RUN apt-get update && apt-get install -y wget curl cron tzdata

# Install OpenLiteSpeed (platform-aware)
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        wget https://openlitespeed.org/packages/openlitespeed-$OLS_VERSION-x86_64-linux.tgz && \
        tar xzf openlitespeed-$OLS_VERSION-x86_64-linux.tgz && cd openlitespeed && ./install.sh && \
        echo 'cloud-docker' > $LS_FD/PLAT && rm -rf /openlitespeed && rm /openlitespeed-$OLS_VERSION-x86_64-linux.tgz; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        wget https://openlitespeed.org/packages/openlitespeed-$OLS_VERSION-aarch64-linux.tgz && \
        tar xzf openlitespeed-$OLS_VERSION-aarch64-linux.tgz && cd openlitespeed && ./install.sh && \
        echo 'cloud-docker' > $LS_FD/PLAT && rm -rf /openlitespeed && rm /openlitespeed-$OLS_VERSION-aarch64-linux.tgz; \
    else \
        echo "$TARGETPLATFORM is not supported" && exit 1; \
    fi

# Setup LiteSpeed repos
RUN wget -O - https://repo.litespeed.sh | bash

# Install PHP, extensions, and MySQL client
RUN apt-get update && apt-get install -y \
    mysql-client $PHP_VERSION $PHP_VERSION-common $PHP_VERSION-mysql \
    $PHP_VERSION-curl $PHP_VERSION-imagick $PHP_VERSION-redis \
    $PHP_VERSION-memcached $PHP_VERSION-intl

RUN ["/bin/bash", "-c", "case \"$PHP_VERSION\" in lsphp81|lsphp82|lsphp83|lsphp84) apt-get install -y ${PHP_VERSION}-opcache ;; esac"]

RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp7* ]]; then apt-get install -y $PHP_VERSION-json; fi"]

# Clean apt cache to reduce image size
RUN rm -rf /var/lib/apt/lists/*

# Fetch admin update script
RUN wget -O $LS_FD/admin/misc/lsup.sh \
    https://raw.githubusercontent.com/litespeedtech/openlitespeed/master/dist/admin/misc/lsup.sh && \
    chmod +x $LS_FD/admin/misc/lsup.sh

# Tune PHP settings for production use
RUN sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' $PHPINI_PATH && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1024M/g' $PHPINI_PATH && \
    sed -i 's/post_max_size = 8M/post_max_size = 1024M/g' $PHPINI_PATH && \
    sed -i 's/max_execution_time = 30/max_execution_time = 300/g' $PHPINI_PATH

# Install WP-CLI and symlink PHP binary
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp && \
	ln -s $LS_FD/$PHP_VERSION/bin/php /usr/bin/php

# Install ACME.sh for SSL certificate management
RUN wget -O -  https://get.acme.sh | sh

EXPOSE 7080
ENV PATH="/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin"

ADD docker.conf $LS_FD/conf/templates/docker.conf
ADD setup_docker.sh $LS_FD/bin/setup_docker.sh
ADD htpasswd $LS_FD/admin/conf/htpasswd

# Setup config, permissions, and config backups (consolidated layer)
RUN $LS_FD/bin/setup_docker.sh && rm $LS_FD/bin/setup_docker.sh \
    && chown 994:994 $LS_FD/conf -R \
    && cp -RP $LS_FD/conf/ $LS_FD/.conf/ \
    && cp -RP $LS_FD/admin/conf $LS_FD/admin/.conf/

# Link PHP binaries based on version
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp8* ]]; then ln -sf $LS_FD/$PHP_VERSION/bin/lsphp $LS_FD/fcgi-bin/lsphp8; fi"]
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp8* ]]; then ln -sf $LS_FD/fcgi-bin/lsphp8 $LS_FD/fcgi-bin/lsphp; fi"]
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp7* ]]; then ln -sf $LS_FD/$PHP_VERSION/bin/lsphp $LS_FD/fcgi-bin/lsphp7; fi"]
RUN ["/bin/bash", "-c", "if [[ $PHP_VERSION == lsphp7* ]]; then ln -sf $LS_FD/fcgi-bin/lsphp7 $LS_FD/fcgi-bin/lsphp; fi"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -sf http://localhost/ -o /dev/null || exit 1

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /var/www/vhosts/
