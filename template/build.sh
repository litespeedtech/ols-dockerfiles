#!/usr/bin/env bash
OLS_VERSION=''
PHP_VERSION=''
PUSH=''
CONFIG=''
TAG=''
BUILDER='litespeedtech'
REPO='openlitespeed'
EPACE='        '
ARCH='linux/amd64'

echow(){
    FLAG=${1}
    shift
    echo -e "\033[1m${EPACE}${FLAG}\033[0m${@}"
}

help_message(){
    echo -e "\033[1mOPTIONS\033[0m" 
    echow '-O, --ols [VERSION] -P, --php [lsphpVERSION]'
    echo "${EPACE}${EPACE}Example: bash build.sh --ols 1.8.2 --php lsphp83"
    echow '--push'
    echo "${EPACE}${EPACE}Example: build.sh --ols 1.8.2 --php lsphp83 --push, will push to the dockerhub"
    echow '--arch'
    echo "${EPACE}${EPACE}Example: build.sh --ols 1.8.2 --php lsphp83 --arch linux/amd64,linux/arm64, will build image for both amd64 and arm64, otherwise linux/amd64 will be applied."    
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
        echo "Build image: ${1} ${2}"
        #docker build . --tag ${BUILDER}/${REPO}:${1}-${2} --build-arg OLS_VERSION=${1} --build-arg PHP_VERSION=${2}
        docker buildx build . --platform ${ARCH} --tag ${BUILDER}/${REPO}:${1}-${2} --build-arg OLS_VERSION=${1} --build-arg PHP_VERSION=${2} --output=type=registry
    fi    
}

test_image(){
    echo "Test image"
    ID=$(docker run -d ${BUILDER}/${REPO}:${1}-${2})
    docker exec -i ${ID} su -c 'mkdir -p /var/www/vhosts/localhost/html/ \
    && echo "<?php phpinfo();" > /var/www/vhosts/localhost/html/index.php \
    && /usr/local/lsws/bin/lswsctrl restart'
    sleep 5
    HTTP=$(docker exec -i ${ID} curl -s -o /dev/null -Ik -w "%{http_code}" http://localhost)
    HTTPS=$(docker exec -i ${ID} curl -s -o /dev/null -Ik -w "%{http_code}" https://localhost)
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

build_push_image(){
    if [ ! -z "${PUSH}" ]; then
        echo 'Push image'
        if [ -f ~/.docker/litespeedtech/config.json ]; then
            CONFIG=$(echo --config ~/.docker/litespeedtech)
        fi
        #docker ${CONFIG} push ${BUILDER}/${REPO}:${1}-${2}
        if [ -z "${TAG}" ]; then
            docker buildx build . --platform ${ARCH} --tag ${BUILDER}/${REPO}:${1}-${2} --build-arg OLS_VERSION=${1} --build-arg PHP_VERSION=${2} --output=type=registry --push
        else
            #docker tag ${BUILDER}/${REPO}:${1}-${2} ${BUILDER}/${REPO}:${3}
            #docker ${CONFIG} push ${BUILDER}/${REPO}:${3}
            docker buildx build . --platform ${ARCH} --tag ${BUILDER}/${REPO}:${3} --build-arg OLS_VERSION=${1} --build-arg PHP_VERSION=${2} --output=type=registry --push
        fi
    else
        echo 'Skip Push.'    
    fi
}

main(){
    build_image ${OLS_VERSION} ${PHP_VERSION}
    test_image ${OLS_VERSION} ${PHP_VERSION}
    build_push_image ${OLS_VERSION} ${PHP_VERSION} ${TAG}
}

check_input ${1}
while [ ! -z "${1}" ]; do
    case ${1} in
        -[hH] | -help | --help)
            help_message
            ;;
        -[oO] | -ols | --ols) shift
            check_input "${1}"
            OLS_VERSION="${1}"
            ;;
        -[pP] | -php | --php) shift
            check_input "${1}"
            PHP_VERSION="${1}"
            ;;
        -[tT] | -tag | -TAG | --tag) shift
            TAG="${1}"
            ;;       
        -[aA] | -arch | --arch) shift
            check_input "${1}"
            ARCH="${1}"
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