docker-devbox
=============

Docker Devbox is a set of tools build on top of Docker that automates environments setup for web applications, from 
development to production.

# Design goals

* Give the developer a clear and native experience, but use docker containers under the hood.
* Isolate each project, but share common patterns and tools.
* Keep control on how containers are built, by keeping `Dockerfile` and `docker-compose.yml` visible and editable.
* Deploy to stage and production environment with no change to the project source code.
* Workaround usual caveats of docker on development environments.

# Features

* Activate the project environment automatically when *cd* into the project folder ([SmartCD](https://github.com/cxreg/smartcd)).
* Access application through `.test` development domain name ([Traefik](https://traefik.io/)).
* Generate trusted SSL certificate automatically through a development certificate authority ([Cloudflare CFSSL](https://github.com/cloudflare/cfssl) or [mkcert](https://github.com/FiloSottile/mkcert))
* Install CA certificates automatically to docker images, to support containers SSL inter-communication and [SSL Corporate proxies](https://security.stackexchange.com/questions/133254/how-does-ssl-proxy-server-in-company-work#answer-133261) like [Palo Alto SSL Inbound Inspection](https://docs.paloaltonetworks.com/pan-os/7-1/pan-os-admin/decryption/ssl-inbound-inspection.html#).
* Brings project containers commands to shell `PATH` and bind current working directory, commands behave as if there were installed right on the host (For example, `composer install` and `npm install` will just work as usual, `psql` and `mysql` can connect to the database).
* Fix usual permission issues by automating local volume directory creation and [fixuid](https://github.com/boxboat/fixuid) integration.
* Configure each target environment (`dev`, `stage`, `prod`) with environment variables only.
* Introduce environment variables into configuration files with a template engine ([Mo - Mustache Templates in Bash](https://github.com/tests-always-included/mo)).
* Enable configuration files matching the active environment with simple symlinks creation automation ([mo pure bash templating engine](https://github.com/tests-always-included/mo)). 
* Switch to a real public domain name with no pain ([Traefik](https://traefik.io/) and [Let's Encrypt](https://letsencrypt.org/)).
* Access application from a private network remotely through an automated SSH tunnel ([ngrok](https://ngrok.com/), [Serveo](https://serveo.net/) or [ssi.sh](https://github.com/antoniomika/sish))

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

This will install everything required for Docker Devbox, but docker, docker-compose and bash should be installed manually 
before.

Docker Devbox will install [Traefik](https://traefik.io/) in a docker container and binds `tcp/80`,`tcp/443` to host, 
so those ports should be available.

Port `tcp/7780` should also be available for CFSSL container (local certificate authority service).

*Installation script may ask for sudo password to install some dependencies, like curl, git and make.*

## Development domain name configuration (`.test`)

To access application through `.test` development domain name, you have to setup your system for those domains to be
resolved as docker host IP.

On Linux, dnsmasq can be used for this purpose.

On Windows, Acrylic DNS proxy can be used for this purpose.

### Configure dnsmasq (Linux)

- Ubuntu Server (without NetworkManager)
```
sudo apt-get install -y dnsmasq

DOCKER_HOST_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')
echo "DOCKER_HOST_IP=$DOCKER_HOST_IP" 
sudo sh -c "echo address=/.test/$DOCKER_HOST_IP>/etc/dnsmasq.d/test-domain-to-docker-host-ip"

sudo service dnsmasq restart
```

- Ubuntu Desktop (with NetworkManager)

NetworkManager from desktop brings it's own dnsmasq daemon.

```
DOCKER_HOST_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')
echo "DOCKER_HOST_IP=$DOCKER_HOST_IP" 
sudo sh -c "echo address=/.test/$DOCKER_HOST_IP>/etc/NetworkManager/dnsmasq.d/test-domain-to-docker-host-ip"

sudo service NetworkManager restart
```

### Configure Acrylic DNS proxy (Windows)

Download [Acrylic DNS proxy](https://mayakron.altervista.org) for Windows, and perform installation.

Then open Acrylic UI and configure the Host configuration with such entry

```
192.168.1.100 *.test
```

The IP address should match the IP of the docker engine.

## Installation environment variables

Environment variables available for installer script:

- `DOCKER_DEVBOX_MINIMAL`: Clone docker-devbox repository and create reverse-proxy network only.
- `DOCKER_DEVBOX_BIN`: Directory available in PATH where tools (cfssl-cli, mkcert) will be installed. Default is `/usr/local/bin`.
- `DOCKER_DEVBOX_DISABLE_OPTIONAL_DEPENDENCIES`: Disable optional dependencies installation.
- `DOCKER_DEVBOX_DISABLE_SMARTCD`: Disable SmartCD.
- `DOCKER_DEVBOX_DISABLE_CFSSL`: Disable CFSSL.
- `DOCKER_DEVBOX_DISABLE_PORTAINER`: Disable portainer.
- `DOCKER_DEVBOX_DISABLE_REVERSE_PROXY`: Disable reverse-proxy feature (both nginx-proxy and traefik).
- `DOCKER_DEVBOX_USE_NGINX_PROXY`: Use nginx-proxy instead of traefik for reverse proxy.
- `DOCKER_DEVBOX_DISABLE_UPDATE`: Disable update of docker-devbox. This may be useful when running installer right from
local repository.
- `DOCKER_DEVBOX_CI`: Equivalent to `DOCKER_DEVBOX_MINIMAL` and `DOCKER_DEVBOX_DISABLE_OPTIONAL_DEPENDENCIES`, recommanded for CI.

Environment variables can be set right before bash invocation in the installer one-liner.

```bash
curl -L https://github.com/gfi-centre-ouest/docker-devbox/raw/master/installer | \
DOCKER_DEVBOX_CI=1 \
bash
```

# Migration

Please read [MIGRATION.md](./MIGRATION.md) to migration machine and projects from previous version.
