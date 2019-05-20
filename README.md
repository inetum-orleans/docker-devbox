docker-devbox
=============

Docker Devbox is a set of tools build on top of Docker that automates your environments for web applications development.

It runs natively on any Linux, but Windows and MacOS users may use 
[docker-devbox-vagrant](https://github.com/gfi-centre-ouest/docker-devbox-vagrant) to setup a ready-to-use 
Docker Devbox inside a Vagrant managed VirtualBox VM based on Ubuntu Server.

# Requirements

* Docker >= 18.09.6
* docker-compose >= 1.24.0
* GNU Bash
* make
* git
* jq (Optional)
* cfssl-cli (Optional)

# Install or Update

```
curl -L https://github.com/gfi-centre-ouest/docker-devbox/raw/master/installer | bash
```

Then, you need to setup your system for `*.test` domains to be resolved as docker host IP.

```
sudo apt-get install -y dnsmasq resolvconf

DOCKER_HOST_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')
echo "DOCKER_HOST_IP=$DOCKER_HOST_IP" 
sudo sh -c "echo address=/.test/$DOCKER_HOST_IP>/etc/dnsmasq.d/test-domain-to-docker-host-ip"

sudo service dnsmasq restart
```

# Optional

Optional dependencies will be downloaded on demand if not already available on the system.


- jq
```
sudo apt-get update && sudo apt-get install -y jq
```

- cfssl-cli

```
CFSSL_CLI_VERSION=$(curl -s https://api.github.com/repos/Toilal/python-cfssl-cli/releases/latest | grep 'tag_name' | cut -d\" -f4)
echo "## Installation de cfssl-cli $CFSSL_CLI_VERSION"

curl -sL -o ./cfssl-cli https://github.com/Toilal/python-cfssl-cli/releases/download/$CFSSL_CLI_VERSION/cfssl-cli
mv ./cfssl-cli /usr/local/bin/cfssl-cli

chmod +x /usr/local/bin/cfssl-cli
```
