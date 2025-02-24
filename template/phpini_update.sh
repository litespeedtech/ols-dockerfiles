#!/bin/bash
LSDIR='/usr/local/lsws'
PHP_MAJOR=$(php -v | head -n 1 | cut -d " " -f 2 | awk -F '.' '{print $1}')
PHP_MINOR=$(php -v | head -n 1 | cut -d " " -f 2 | awk -F '.' '{print $2}')
PHPINICONF="${LSDIR}/lsphp${PHP_MAJOR}${PHP_MINOR}/etc/php/${PHP_MAJOR}.${PHP_MINOR}/litespeed/php.ini"

linechange(){
    LINENUM=$(grep -n "${1}" ${2} | cut -d: -f 1)
    if [ -n "$LINENUM" ] && [ "$LINENUM" -eq "$LINENUM" ] 2>/dev/null; then
        sed -i "${LINENUM}d" ${2}
        sed -i "${LINENUM}i${3}" ${2}
    fi
}

config_php(){
    echo 'Updating PHP Paremeter'
    NEWKEY='max_execution_time = 360'
    linechange 'max_execution_time' ${PHPINICONF} "${NEWKEY}"
    NEWKEY='post_max_size = 256M'
    linechange 'post_max_size' ${PHPINICONF} "${NEWKEY}"
    NEWKEY='upload_max_filesize = 256M'
    linechange 'upload_max_filesize' ${PHPINICONF} "${NEWKEY}"
    NEWKEY="memory_limit = 1024M"
    linechange 'memory_limit' ${PHPINICONF} "${NEWKEY}"
    killall lsphp >/dev/null 2>&1 
    echo 'Finish PHP Paremeter'
}

config_php