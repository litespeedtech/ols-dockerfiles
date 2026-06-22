ARG UBUNTU_VERSION=26.04
FROM ubuntu:${UBUNTU_VERSION}
ARG OLS_VERSION
ARG PHP_VERSION
ARG TARGETPLATFORM

ENV LS_FD='/usr/local/lsws'
ENV PHPINI_PATH="$LS_FD/$PHP_VERSION/etc/php/*/litespeed/php.ini"

RUN apt-get update && apt-get install -y --no-install-recommends \
        wget curl cron unzip ed tzdata ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        OLS_ARCH='x86_64'; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        OLS_ARCH='aarch64'; \
    else \
        echo "$TARGETPLATFORM is not supported" >&2; exit 1; \
    fi; \
    OLS_TGZ="openlitespeed-${OLS_VERSION}-${OLS_ARCH}-linux.tgz"; \
    wget --tries=3 --timeout=60 -q "https://openlitespeed.org/packages/${OLS_TGZ}"; \
    tar xzf "${OLS_TGZ}"; \
    cd openlitespeed && ./install.sh; \
    echo 'cloud-docker' > "$LS_FD/PLAT"; \
    cd / && rm -rf /openlitespeed "/${OLS_TGZ}"

RUN set -eux; \
    wget --tries=3 --timeout=60 -qO /tmp/repo.litespeed.sh https://repo.litespeed.sh; \
    bash /tmp/repo.litespeed.sh; \
    rm -f /tmp/repo.litespeed.sh

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        mysql-client \
        $PHP_VERSION $PHP_VERSION-common $PHP_VERSION-mysql \
        $PHP_VERSION-curl $PHP_VERSION-imagick $PHP_VERSION-redis \
        $PHP_VERSION-memcached $PHP_VERSION-intl; \
    case "$PHP_VERSION" in \
        lsphp81|lsphp82|lsphp83|lsphp84) \
            apt-get install -y --no-install-recommends "${PHP_VERSION}-opcache" ;; \
        lsphp7*) \
            apt-get install -y --no-install-recommends "${PHP_VERSION}-json" ;; \
    esac; \
    rm -rf /var/lib/apt/lists/*

RUN wget --tries=3 --timeout=60 -qO $LS_FD/admin/misc/lsup.sh \
    https://raw.githubusercontent.com/litespeedtech/openlitespeed/master/dist/admin/misc/lsup.sh && \
    chmod +x $LS_FD/admin/misc/lsup.sh

RUN sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' $PHPINI_PATH && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1024M/g' $PHPINI_PATH && \
    sed -i 's/post_max_size = 8M/post_max_size = 1024M/g' $PHPINI_PATH && \
    sed -i 's/max_execution_time = 30/max_execution_time = 300/g' $PHPINI_PATH

RUN set -eux; \
    curl -fsSL -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; \
    curl -fsSL -o /tmp/wp-cli.phar.sha512 https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar.sha512; \
    echo "$(cat /tmp/wp-cli.phar.sha512)  /tmp/wp-cli.phar" | sha512sum -c -; \
    chmod +x /tmp/wp-cli.phar; \
    mv /tmp/wp-cli.phar /usr/bin/wp; \
    rm -f /tmp/wp-cli.phar.sha512; \
    ln -s $LS_FD/$PHP_VERSION/bin/php /usr/bin/php

RUN set -eux; \
    wget --tries=3 --timeout=60 -qO /tmp/acme.sh https://get.acme.sh; \
    sh /tmp/acme.sh; \
    rm -f /tmp/acme.sh

EXPOSE 7080
ENV PATH="/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin"

ADD docker.conf $LS_FD/conf/templates/docker.conf
ADD setup_docker.sh $LS_FD/bin/setup_docker.sh
ADD htpasswd $LS_FD/admin/conf/htpasswd

RUN $LS_FD/bin/setup_docker.sh && rm $LS_FD/bin/setup_docker.sh
RUN chown -R lsadm:lsadm $LS_FD/conf $LS_FD/admin/conf
RUN chmod -R u=rwX,go= $LS_FD/admin/conf
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
