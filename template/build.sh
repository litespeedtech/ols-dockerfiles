#!/usr/bin/env bash
OLS_VERSION=''
PHP_VERSION=''
PUSH=''
CONFIG=''
TAG=''
BUILDER='litespeedtech'
REPO='openlitespeed-beta'

help_message(){
    echo 'Command [-ols XX] [-php lsphpXX]'
    echo 'Command [-ols XX] [-php lsphpXX] --push'
    echo 'Example: build.sh -ols 1.6.8 -php lsphp74 --push'
    exit 0
}

check_input(){
    if [ -z "${1}" ]; then
        help_message
    fi
}

build_image(){
    if [ -z "${1}" ] || [ -z "${2}" ]; then
        help_message
    else
        echo "${1} ${2}"
        if [ ! -z "${TAG}" ]; then
            docker build . --tag ${BUILDER}/${REPO}:${TAG} --build-arg OLS_VERSION=${1} --build-arg PHP_VERSION=${2}
        else
            docker build . --tag ${BUILDER}/${REPO}:${1}-${2} --build-arg OLS_VERSION=${1} --build-arg PHP_VERSION=${2}
        fi    
    fi    
}

test_image(){
    ID=$(docker run -d ${BUILDER}/${REPO}:${1}-${2})
    docker exec -it ${ID} su -c 'mkdir -p /var/www/vhosts/localhost/html/ \
    && echo "<?php phpinfo();" > /var/www/vhosts/localhost/html/index.php \
    && /usr/local/lsws/bin/lswsctrl restart'
    HTTP=$(docker exec -it ${ID} curl -s -o /dev/null -Ik -w "%{http_code}" http://localhost)
    HTTPS=$(docker exec -it ${ID} curl -s -o /dev/null -Ik -w "%{http_code}" https://localhost)
    docker kill ${ID}
    if [[ "${HTTP}" != "200" || "${HTTPS}" != "200" ]]; then
        echo '[X] Test failed!'
        echo "http://localhost returned ${HTTP}"
        echo "https://localhost returned ${HTTPS}"
        exit 1
    else
        echo '[O] Tests passed!' 
    fi
}

push_image(){
    if [ ! -z "${PUSH}" ]; then
        if [ -f ~/.docker/litespeedtech/config.json ]; then
            CONFIG=$(echo --config ~/.docker/litespeedtech)
        fi
        docker ${CONFIG} push ${BUILDER}/${REPO}:${1}-${2}
        if [ ! -z "${TAG}" ]; then
            docker ${CONFIG} push ${BUILDER}/${REPO}:${TAG}
        fi
    else
        echo 'Skip Push.'    
    fi
}

main(){
    build_image ${OLS_VERSION} ${PHP_VERSION} ${TAG}
    test_image ${OLS_VERSION} ${PHP_VERSION}
    push_image ${OLS_VERSION} ${PHP_VERSION} ${TAG}
}

check_input ${1}
while [ ! -z "${1}" ]; do
    case ${1} in
        -[hH] | -help | --help)
            help_message
            ;;
        -ols | -OLS_VERSION | -O) shift
            check_input "${1}"
            OLS_VERSION="${1}"
            ;;
        -php | -PHP_VERSION | -P) shift
            check_input "${1}"
            PHP_VERSION="${1}"
            ;;
        -tag | -TAG | -T) shift
            TAG="${1}"
            ;;       
        --push ) shift
            PUSH=true
            ;;            
        *) 
            help_message
            ;;              
    esac
    shift
done

main