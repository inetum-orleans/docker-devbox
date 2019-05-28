Migration
---------

This is a migration guide for people using old project skeletons based on a hard-coded `nginx-proxy` network inside 
`docker-compose.override.dev.yml` (projects generated with 
[generator-docker-devbox](https://github.com/gfi-centre-ouest/generator-docker-devbox) < 1.4)

New projects generated with [generator-docker-devbox](https://github.com/gfi-centre-ouest/generator-docker-devbox) >= 1.4 
can run through both nginx-proxy and traefik, but you should keep in mind that a single reverse proxy can run at the 
same time on the host.

- Delete old nginx-proxy containers

```bash
docker rm -f nginx-proxy nginx-proxy-fallback
```

- Install dependencies

```bash
sudo apt-get update && sudo apt-get install -y make jq

CFSSL_CLI_VERSION=$(curl -s https://api.github.com/repos/Toilal/python-cfssl-cli/releases/latest | grep 'tag_name' | cut -d\" -f4)
echo "## Installation de cfssl-cli $CFSSL_CLI_VERSION"

curl -sL -o ./cfssl-cli https://github.com/Toilal/python-cfssl-cli/releases/download/$CFSSL_CLI_VERSION/cfssl-cli
sudo mv ./cfssl-cli /usr/local/bin/cfssl-cli

sudo chmod +x /usr/local/bin/cfssl-cli

MKCERT_VERSION=$(curl -s https://api.github.com/repos/FiloSottile/mkcert/releases/latest | grep 'tag_name' | cut -d\" -f4)
echo "## Installation de mkcert $MKCERT_VERSION"

curl -fsSL -o ./mkcert "https://github.com/FiloSottile/mkcert/releases/download/$MKCERT_VERSION/mkcert-$MKCERT_VERSION-linux-amd64"
sudo mv ./mkcert /usr/local/bin/mkcert

sudo chmod +x /usr/local/bin/mkcert
```

- Run docker-devbox installer with `DOCKER_DEVBOX_USE_NGINX_PROXY` environment variable

```bash
DOCKER_DEVBOX_USE_NGINX_PROXY=1 curl -L https://github.com/gfi-centre-ouest/docker-devbox/raw/master/installer | bash
```

- Add system environment variables
[defined here](https://github.com/gfi-centre-ouest/docker-devbox-vagrant/blob/master/config.example.yaml#L11-L18) 
(inside `config.yaml` for [docker-devbox-vagrant](https://github.com/gfi-centre-ouest/docker-devbox-vagrant) users)

- set `DOCKER_DEVBOX_REVERSE_PROXY_NETWORK` environment variable to `nginx-proxy`. (in config.yaml )



    - `ln -fs ~/.docker-devbox/certs ~/.nginx-proxy/certs`
    - `ln -fs ~/.docker-devbox/nginx-proxy/vhost.d ~/.nginx-proxy/vhost.d`

- Add sy


# Supprimer l'ancien container nginx-proxy



# Installer du nouveau nginx-proxy

cd ~/.docker-devbox/nginx-proxy

dc up -d


 


# Créer des liens symboliques pour que les anciens projets fonctionnent encore

ln -fs ~/.docker-devbox/certs ~/.nginx-proxy/certs
ln -fs ~/.docker-devbox/nginx-proxy/vhost.d ~/.nginx-proxy/vhost.d
