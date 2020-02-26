# OpenLiteSpeed Docker Container
[![Build Status](https://travis-ci.com/litespeedtech/ols-docker-env.svg?branch=master)](https://hub.docker.com/r/litespeedtech/openlitespeed)
[![OpenLiteSpeed](https://img.shields.io/badge/openlitespeed-1.6.9-informational?style=flat&color=blue)](https://hub.docker.com/r/litespeedtech/openlitespeed)
[![docker pulls](https://img.shields.io/docker/pulls/litespeedtech/openlitespeed?style=flat&color=blue)](https://hub.docker.com/r/litespeedtech/openlitespeed)
[<img src="https://img.shields.io/badge/slack-LiteSpeed-blue.svg?logo=slack">](litespeedtech.com/slack) 
[<img src="https://img.shields.io/twitter/follow/litespeedtech.svg?label=Follow&style=social">](https://twitter.com/litespeedtech)

Install a lightweight OpenLiteSpeed container using either the Edge or Stable version in Ubuntu 18.04 Linux.

### Prerequisites
*  [Install Docker](https://www.docker.com/)

## Build Components
The system will regulary build both OpenLiteSpeed Edge and Latest stable versions, along with the last two PHP versions.

|Component|Version|
| :-------------: | :-------------: |
|Linux|Ubuntu 18.04|
|OpenLiteSpeed|[Edge stable version](https://openlitespeed.org/release-log/version-1-6-x)|
|OpenLiteSpeed|[Latest stable version](https://openlitespeed.org/release-log/version-1-5-x)|
|PHP|[Latest stable version](http://rpms.litespeedtech.com/debian/)|

## Usage
### Download an image
Download the openlitespeed image, we can use latest for latest version
```
docker pull litespeedtech/openlitespeed:latest
```
or specify the OpenLiteSpeed version with lsphp version
```
docker pull litespeedtech/openlitespeed:1.6.9-lsphp74
```
### Starting a Container
```
docker run --name openlitespeed -p 7080:7080 -p 80:80 -p 443:443 -it litespeedtech/openlitespeed:latest
```
You can also run with Detached mode, like so:
```
docker run -d --name openlitespeed -p 7080:7080 -p 80:80 -p 443:443 -it litespeedtech/openlitespeed:latest
```
### Stopping a Container
Feel free to substitute the "openlitespeed" to the "Container_ID" if you did not define any name for the container.
```
docker stop openlitespeed
```

## Support & Feedback
If you still have a question after using OpenLiteSpeed Docker, you have a few options.
* Join [the GoLiteSpeed Slack community](litespeedtech.com/slack) for real-time discussion
* Post to [the OpenLiteSpeed Forums](https://forum.openlitespeed.org/) for community support
* Reporting any issue on [Github ols-dockerfiles](https://github.com/litespeedtech/ols-dockerfiles/issues) project

**Pull requests are always welcome** 