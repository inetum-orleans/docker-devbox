docker-devbox
=============

Docker Devbox is a set of tools build on top of Docker that automates environments setup for web applications, from 
development to production.

# Design goals

* Give the developer the same experience as if everything was locally installed on his computer, but use docker 
  containers under the hood.
* Isolate each project while being able to switch quickly from one project to another.
* Deploy to staging and production environment using the same environment as the developer one.

# Features

* Domain name support ([Traefik](https://traefik.io/) by default, [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) as an option)
* Automated SSL certificate generation ([Cloudflare CFSSL](https://github.com/cloudflare/cfssl) by default, [mkcert](https://github.com/FiloSottile/mkcert) as an option)
* Mustache based template engine and automatic symlink creating to configure various environments (dev, stage, prod) ([mo pure base templating engine](https://github.com/tests-always-included/mo))  

# Requirements

Docker Devbox runs natively on any Linux only, but Windows and MacOS users may use 
[docker-devbox-vagrant](https://github.com/gfi-centre-ouest/docker-devbox-vagrant) to run it inside a Vagrant managed 
VirtualBox VM based on Ubuntu Server.

* Docker >= 18.09.6
* docker-compose >= 1.24.0
* GNU Bash

# Install or Update

```
curl -L https://github.com/gfi-centre-ouest/docker-devbox/raw/master/installer | bash
```

This will install everything required for Docker Devbox, including the following tools:

* make
* [jq](https://stedolan.github.io/jq/)
* [cfssl-cli](https://github.com/Toilal/python-cfssl-cli)
* [mkcert](https://github.com/FiloSottile/mkcert)

*Installation script may ask for sudo password to install those dependencies.*

Environment variables available for installer script:

- `DOCKER_DEVBOX_MINIMAL`: Clone docker-devbox repository and create reverse-proxy network only.
- `DOCKER_DEVBOX_BIN`: Directory available in PATH where tools (cfssl-cli, mkcert) will be installed. Default is `/usr/local/bin`.
- `DOCKER_DEVBOX_DISABLE_TOOLS`: Disable tools.
- `DOCKER_DEVBOX_DISABLE_SMARTCD`: Disable SmartCD.
- `DOCKER_DEVBOX_DISABLE_CFSSL`: Disable CFSSL.
- `DOCKER_DEVBOX_DISABLE_PORTAINER`: Disable portainer.
- `DOCKER_DEVBOX_DISABLE_REVERSE_PROXY`: Disable reverse-proxy feature (both nginx-proxy and traefik).
- `DOCKER_DEVBOX_USE_NGINX_PROXY`: Use nginx-proxy instead of traefik for reverse proxy.
- `DOCKER_DEVBOX_DISABLE_UPDATE`: Disable update of docker-devbox. This may be useful when running installer right from
local repository.

# .test as a docker host domain

You have to setup your system for `.test` domains to be resolved as docker host IP.

dnsmasq can be used for this purpose.

- Ubuntu Server (without NetworkManager)
```
sudo apt-get install -y dnsmasq

DOCKER_HOST_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')
echo "DOCKER_HOST_IP=$DOCKER_HOST_IP" 
sudo sh -c "echo address=/.test/$DOCKER_HOST_IP>/etc/dnsmasq.d/test-domain-to-docker-host-ip"

sudo service dnsmasq restart
```

- Ubuntu Desktop (with NetworkManager)

```
DOCKER_HOST_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')
echo "DOCKER_HOST_IP=$DOCKER_HOST_IP" 
sudo sh -c "echo address=/.test/$DOCKER_HOST_IP>/etc/NetworkManager/dnsmasq.d/test-domain-to-docker-host-ip"

sudo service NetworkManager restart
```

# Quick migration from previous version
