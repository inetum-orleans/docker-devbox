docker-devbox
=============

Docker Devbox is a set of tools build on top of Docker that automates your environments for web applications development.

It runs natively on any Linux, but [docker-devbox-vagrant](https://github.com/gfi-centre-ouest/docker-devbox-vagrant) 
is available to setup ready-to-use bash for Windows and MacOS users.

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
