#!/bin/bash

# Restore default config if volumes are empty
if [ -z "$(ls -A -- "/usr/local/lsws/conf/")" ]; then
	cp -R /usr/local/lsws/.conf/* /usr/local/lsws/conf/
fi
if [ -z "$(ls -A -- "/usr/local/lsws/admin/conf/")" ]; then
	cp -R /usr/local/lsws/admin/.conf/* /usr/local/lsws/admin/conf/
fi
chown 994:994 /usr/local/lsws/conf -R
chown 994:1001 /usr/local/lsws/admin/conf -R

# Graceful shutdown handler
shutdown() {
    echo "Received shutdown signal, stopping OpenLiteSpeed..."
    /usr/local/lsws/bin/lswsctrl stop
    exit 0
}
trap shutdown SIGTERM SIGINT

/usr/local/lsws/bin/lswsctrl start
$@

# Monitor OLS process; exit if it dies
while true; do
	if ! /usr/local/lsws/bin/lswsctrl status | /usr/bin/grep 'litespeed is running with PID *' > /dev/null; then
		break
	fi
	sleep 60
done
