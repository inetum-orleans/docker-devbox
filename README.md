docker-devbox
=============

Docker Devbox is a set of tools build on top of Docker that automates environments setup for web applications, from 
development to production.

It relies on [ddb](https://gfi-centre-ouest.github.io/docker-devbox-ddb/), a command line tool that provides 
features to generate, activate and adjust configuration files based on a single overridable and extendable 
configuration, while enhancing the developer experience and reducing manual operations.

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
* GNU Bash >= 4.0
* curl

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

#### Linux (dnsmasq)

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

#### Windows (Acrylic DNS proxy)

Download [Acrylic DNS proxy](https://mayakron.altervista.org) for Windows, and perform installation.

Then open Acrylic UI and configure the Host configuration with such entry

```
192.168.1.100 *.test
```

The IP address should match the IP of the docker engine.

## Configure local CA certificate

Docker Devbox automatically generates development certificate for HTTPS support, but you need to register the local 
CA certificate using mkcert.

#### Linux

Run the following commands from docker devbox shell.

```
# This dependency is required to support Chrome and Firefox.
sudo apt-get install libnss3-tools

# Get mkcert path in a variable
MKCERT_EXE=$(command -v mkcert)

# Uninstall any previous CA cert
sudo -E $MKCERT_EXE -uninstall

# Move to cfssl container directory
cd ~/.docker-devbox/cfssl

# Replace default mkcert key/pair with CFSSL public key.
sudo rm -Rf ../certs/mkcert-ca && mkdir -p ../certs/mkcert-ca
docker cp $(docker-compose ps -q intermediate):/etc/cfssl/ca.pem ../certs/mkcert-ca/rootCA.pem

# Install CFSSL CA Certificate with mkcert.
sudo -E $MKCERT_EXE -install 
```

#### Windows

On Windows, you should install the CA certificate inside the VM where docker-devbox is installed with the previous
linux procedure, but you should also install the CA certificate on your host, for browser to aknowlegdge the
development certificates. 

- Download [mkcert for Windows](https://github.com/FiloSottile/mkcert/releases), and set `CAROOT` environment variable 
to some directory, like `C:\mkcert-ca`.

- Extract the CFSSL ca certificate from docker with the following command

```
# Inside docker-devbox shell
cd ~/.docker-devbox/cfssl
docker cp $(docker-compose ps -q intermediate):/etc/cfssl/ca.pem ../certs/mkcert-ca/rootCA.pem
```

- Copy `~/.docker-devbox/certs/mkcert-ca/rootCA.pem` to the host, inside `CAROOT` 
directory.

- Close all `cmd.exe`, and open a new one to check that `CAROOT` environment variable is defined.

```
# This should output CAROOT environment variable
mkcert -CAROOT
```

- Install CA certificate
```
mkcert -install
```

## Installation environment variables

Environment variables available for installer script:

- `DOCKER_DEVBOX_MINIMAL`: Clone docker-devbox repository and create reverse-proxy network only.
- `DOCKER_DEVBOX_DISABLE_SMARTCD`: Disable SmartCD.
- `DOCKER_DEVBOX_DISABLE_CFSSL`: Disable CFSSL.
- `DOCKER_DEVBOX_DISABLE_PORTAINER`: Disable portainer.
- `DOCKER_DEVBOX_DISABLE_REVERSE_PROXY`: Disable reverse-proxy feature.
- `DOCKER_DEVBOX_DISABLE_UPDATE`: Disable update of docker-devbox. This may be useful when running installer right from
local repository.
- `DOCKER_DEVBOX_CI`: Equivalent to `DOCKER_DEVBOX_MINIMAL` and `DOCKER_DEVBOX_DISABLE_OPTIONAL_DEPENDENCIES`, recommanded for CI.
- `DOCKER_DEVBOX_BRANCH`: Use a custom docker-devbox branch.

Environment variables can be set right before bash invocation in the installer one-liner.

```bash
curl -L https://github.com/gfi-centre-ouest/docker-devbox/raw/master/installer | \
DOCKER_DEVBOX_CI=1 \
bash
```

# Initialize a new project

Use [Yeoman](https://yeoman.io/) with [gfi-centre-ouest/generator-docker-devbox](https://github.com/gfi-centre-ouest/generator-docker-devbox) generator to scaffold a new project from interactive questions.

As an alternative, you may grab a sample project from [gfi-centre-ouest/docker-devbox-examples](https://github.com/gfi-centre-ouest/docker-devbox-examples) repository, and edit to fit your needs.

## Make project commands available globally

If you need to access some commands from a docker-devbox project globally from any other directory inside your host, 
you may run the following command from the project directory.

```
docker-devbox bin global
```

This bring the project commands from projects `.bin` directory into the current user `~/bin` directory, and configures 
them for an external usage. This directory is in the user `PATH` by default on most linux distribution, but you may 
have to restart the shell at the first time.

To remove global commands from a project, run the following command from the project directory.

```
docker-devbox bin local
```

# Migration

Please read [MIGRATION.md](./MIGRATION.md) to migration machine and projects from previous version.
