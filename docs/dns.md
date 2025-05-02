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
sudo sh -c "echo address=/.test/$DOCKER_HOST_IP>/etc/dnsmasq.d/test-domain-to-docker-host-ip"

sudo service dnsmasq restart
```

- Ubuntu Desktop (with NetworkManager)

NetworkManager from desktop brings it's own dnsmasq daemon.

```
sudo mv /etc/resolv.conf /etc/resolve.conf.bak
sudo ln -s /var/run/NetworkManager/resolv.conf /etc/resolv.conf

sudo sh -c 'cat << EOF > /etc/NetworkManager/conf.d/use-dnsmasq.conf
[main]
dns=dnsmasq
EOF'

sudo sh -c 'cat << EOF > /etc/NetworkManager/dnsmasq.d/test-domain-to-docker-host-ip
address=/.test/$(ip -4 addr show docker0 | grep -Po "inet \K[\d.]+")
EOF'

sudo service NetworkManager restart
```

#### Windows (Acrylic DNS proxy)

Download [Acrylic DNS proxy](https://mayakron.altervista.org) for Windows, and perform installation.

Then open Acrylic UI and configure the Host configuration with such entry

```
192.168.1.100 *.test
```

The IP address should match the IP of the docker engine.
