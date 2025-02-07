# OpenLiteSpeed Docker Container
[![Build Status](https://github.com/litespeedtech/ols-dockerfiles/workflows/docker-build/badge.svg)](https://github.com/litespeedtech/ols-dockerfiles/actions/new)
[![docker pulls](https://img.shields.io/docker/pulls/litespeedtech/openlitespeed?style=flat&color=blue)](https://hub.docker.com/r/litespeedtech/openlitespeed)
[<img src="https://img.shields.io/badge/slack-LiteSpeed-blue.svg?logo=slack">](litespeedtech.com/slack) 
[<img src="https://img.shields.io/twitter/follow/litespeedtech.svg?label=Follow&style=social">](https://twitter.com/litespeedtech)

Install a lightweight OpenLiteSpeed container using either the Edge or Stable version in Ubuntu 24.04 Linux.

### Prerequisites
*  [Install Docker](https://www.docker.com/)

## Build Components
The system will regulary build both OpenLiteSpeed Edge and Latest stable versions, along with the last two PHP versions.

|Component|Version|
| :-------------: | :-------------: |
|Linux|Ubuntu 24.04|
|OpenLiteSpeed|[Latest stable version](https://openlitespeed.org/release-log/version-1-8-x)|
|PHP|[Latest stable version](http://rpms.litespeedtech.com/debian/)|

## Usage
### Download an image
Download the openlitespeed image, we can use latest for latest version
```
docker pull litespeedtech/openlitespeed:latest
```
or specify the OpenLiteSpeed version with lsphp version
```
docker pull litespeedtech/openlitespeed:1.8.3-lsphp83
```
### Start a Container
```
docker run --name openlitespeed -p 7080:7080 -p 80:80 -p 443:443 -it litespeedtech/openlitespeed:latest
```
You can also run with Detached mode, like so:
```
docker run -d --name openlitespeed -p 7080:7080 -p 80:80 -p 443:443 -it litespeedtech/openlitespeed:latest
```
Tip, you can get rid of `-p 7080:7080` from the command if you don’t need the web admin access.  

### Add a sample page
The server should start running successfully, and you should be able to log into the container. Add some files you want to display with the following command:
```
docker exec -it openlitespeed bash
```
Your default `WORKDIR` should be `/var/www/vhosts/`, since the default document root path is `/var/www/vhosts/localhost/html`. Simply add the following command to `index.php`, then we can verify it from the browser with a public server IP address on both HTTP and HTTPS. 
```
echo '<?php phpinfo();' > localhost/html/index.php
```

### Stop a Container
Feel free to substitute the "openlitespeed" to the "Container_ID" if you did not define any name for the container.
```
docker stop openlitespeed
```

## Customization
Sometimes you may want to install more packages from the default image, or some other web server or PHP version which is not officially provided. You can build an image based on an existing image. Here’s how:
  1. Download the dockerfile project 
  2. `cd` into the project directory
  3. Edit the Dockerfile here if necessary
  4. Build, feeling free to substitute server and PHP versions to fit your needs 

For example,
```
git clone https://github.com/litespeedtech/ols-dockerfiles.git
cd ols-dockerfiles/template
bash build.sh -O 1.7.16 -P lsphp81
```

## Support & Feedback
If you still have a question after using OpenLiteSpeed Docker, you have a few options.
* Join [the GoLiteSpeed Slack community](https://litespeedtech.com/slack) for real-time discussion
* Post to [the OpenLiteSpeed Forums](https://forum.openlitespeed.org/) for community support
* Reporting any issue on [Github ols-dockerfiles](https://github.com/litespeedtech/ols-dockerfiles/issues) project

**Pull requests are always welcome** 