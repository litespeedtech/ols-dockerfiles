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
  listeners               Default, HTTP, HTTPS
  note                    test

  member localhost {
    vhDomain              localhost, *
  }
}

" >> /usr/local/lsws/conf/httpd_config.conf