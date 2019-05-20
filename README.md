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
* make
* git
* jq (Optional)
* cfssl-cli (Optional)
* mkcert (Optional)

# Install or Update

```
curl -L https://github.com/gfi-centre-ouest/docker-devbox/raw/master/installer | bash
```

*Installation script may ask for sudo password to install local developement CA Certificates.*

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

# Optional

Optional dependencies will be downloaded on demand if not already available on the system, but you should install
them manually.


- jq
```
sudo apt-get install -y jq
```

- cfssl-cli

```
CFSSL_CLI_VERSION=$(curl -s https://api.github.com/repos/Toilal/python-cfssl-cli/releases/latest | grep 'tag_name' | cut -d\" -f4)
echo "## Installation de cfssl-cli $CFSSL_CLI_VERSION"

curl -sL -o ./cfssl-cli https://github.com/Toilal/python-cfssl-cli/releases/download/$CFSSL_CLI_VERSION/cfssl-cli
sudo mv ./cfssl-cli /usr/local/bin/cfssl-cli

sudo chmod +x /usr/local/bin/cfssl-cli
```

- mkcert

```
MKCERT_VERSION=$(curl -s https://api.github.com/repos/FiloSottile/mkcert/releases/latest | grep 'tag_name' | cut -d\" -f4)

curl -fsSL -o ./mkcert" "https://github.com/FiloSottile/mkcert/releases/download/$MKCERT_VERSION/mkcert-$MKCERT_VERSION-linux-amd64"
sudo mv ./mkcert /usr/local/bin/mkcert

sudo chmod +x /usr/local/bin/mkcert
```
