#!/usr/bin/env bash
echo "listener HTTP {
  address                 *:80
  secure                  0
}

listener HTTPS {
  address                 *:443
  secure                  1
  keyFile                 /usr/local/lsws/admin/conf/webadmin.key
  certFile                /usr/local/lsws/admin/conf/webadmin.crt
}

vhTemplate docker {
  templateFile            conf/templates/docker.conf
  listeners               HTTP, HTTPS
  note                    docker

  member localhost {
    vhDomain              localhost, *
  }
}

" >> /usr/local/lsws/conf/httpd_config.conf

mkdir -p /var/www/vhosts/localhost/{html,logs,certs}
chown 1000:1000 /var/www/vhosts/localhost/ -R