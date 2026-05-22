#!/bin/bash
if [ -z "$(ls -A -- "/usr/local/lsws/conf/")" ]; then
  cp -R /usr/local/lsws/.conf/* /usr/local/lsws/conf/
fi
if [ -z "$(ls -A -- "/usr/local/lsws/admin/conf/")" ]; then
  cp -R /usr/local/lsws/admin/.conf/* /usr/local/lsws/admin/conf/
fi
if ! id -u lsadm >/dev/null 2>&1 || ! getent group lsadm >/dev/null 2>&1; then
	echo "ERROR: lsadm user or group missing from this image" >&2
	exit 1
fi
chown -R lsadm:lsadm /usr/local/lsws/conf
chown -R lsadm:lsadm /usr/local/lsws/admin/conf
chmod -R u=rwX,go= /usr/local/lsws/admin/conf

/usr/local/lsws/bin/lswsctrl start
"$@"
while true; do
  if ! /usr/local/lsws/bin/lswsctrl status | /usr/bin/grep 'litespeed is running with PID *' > /dev/null; then
    break
  fi
  sleep 60
done