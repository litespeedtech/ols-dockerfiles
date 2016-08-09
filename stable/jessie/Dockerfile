FROM debian:jessie 

MAINTAINER lsadm "info@litespeedtech.com"

ENV OLS_VER 1.4.21-2~jessie
ENV PATH /usr/local/lsws/bin:$PATH

RUN	echo "deb http://rpms.litespeedtech.com/debian/ jessie main" > /etc/apt/sources.list.d/lst_debian_repo.list \
	&& apt-key adv --fetch-keys http://rpms.litespeedtech.com/debian/lst_debian_repo.gpg \
	&& apt-get update && apt-get install -y \
				libgssapi-krb5-2 \
				openlitespeed \
				lsphp56 \
				lsphp56-mysql \
				lsphp56-gd \
				lsphp56-mcrypt \
				lsphp56-imap \
	&& ln -sf /usr/local/lsws/lsphp56/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5 \
	&& sed -i 's/8088/80/g' /usr/local/lsws/conf/httpd_config.conf \
	&& sed -i 's/indexFiles index.html/indexFiles index.html,index.php/g' /usr/local/lsws/conf/vhosts/Example/vhconf.conf \
	&& rm -rf /var/lib/apt/lists/*

RUN	ln -sf /dev/stdout /usr/local/lsws/logs/access.log \
	&& ln -sf /dev/stderr /usr/local/lsws/logs/error.log


EXPOSE 80 7080 443


CMD ["openlitespeed", "-n"]

