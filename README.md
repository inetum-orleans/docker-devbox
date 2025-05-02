docker-devbox
=============

Docker Devbox is a set of tools build on top of Docker that automates environments setup for web applications, from
development to production.

It relies on [ddb](https://inetum-orleans.github.io/docker-devbox-ddb/), a command line tool that provides
features to generate, activate and adjust configuration files based on a single overridable and extendable
configuration, while enhancing the developer experience and reducing manual operations.

This project has no relationship with [Microsoft Dev Box](https://azure.microsoft.com/en-us/products/dev-box)
that has been created after this project.

Docker Devbox does not need Docker Desktop, and, as we understand it, is usable in a commercial company at no cost.

# Design goals

* Give the developer a clear and native experience, but use docker containers under the hood.
* Isolate each project, but share common patterns and tools.
* Keep control on how containers are built, by keeping `Dockerfile` and `docker-compose.yml` visible and editable.
* Deploy to stage and production environment with no change to the project source code.
* Workaround usual caveats of docker on development environments.

# Features

* Activate the project environment automatically when *cd* into the project
  folder ([SmartCD](https://github.com/cxreg/smartcd)).
* Access application through `.test` development domain name ([Traefik](https://traefik.io/)).
* Generate trusted SSL certificate automatically through a development certificate
  authority ([Cloudflare CFSSL](https://github.com/cloudflare/cfssl) or [mkcert](https://github.com/FiloSottile/mkcert))
* Install CA certificates automatically to docker images, to support containers SSL inter-communication
  and [SSL Corporate proxies](https://security.stackexchange.com/questions/133254/how-does-ssl-proxy-server-in-company-work#answer-133261)
  like [Palo Alto SSL Inbound Inspection](https://docs.paloaltonetworks.com/pan-os/7-1/pan-os-admin/decryption/ssl-inbound-inspection.html#)
  .
* Brings project containers commands to shell `PATH` and bind current working directory, commands behave as if there
  were installed right on the host (For example, `composer install` and `npm install` will just work as usual, `psql`
  and `mysql` can connect to the database).
* Fix usual permission issues by automating local volume directory creation
  and [fixuid](https://github.com/boxboat/fixuid) integration.
* Configure each target environment (`dev`, `stage`, `prod`) with environment variables only.
* Introduce environment variables into configuration files with a template
  engine ([Jinja](https://jinja.palletsprojects.com/en/stable/), [Jsonnet](https://jsonnet.org/) and [ytt](https://carvel.dev/ytt/)) and automatically add them to the .gitignore file.
* Enable configuration files matching the active environment with simple symlinks creation
  automation.
* Switch to a real public domain name with no pain ([Traefik](https://traefik.io/)
  and [Let's Encrypt](https://letsencrypt.org/)).
* DJP (ddb jsonnet packages): docker + configuration + tools to quickly bootstrap a project ([Cookiecutter](https://github.com/cookiecutter/cookiecutter))
* ...

# Setup
## Requirements

As the name implies, Docker Devbox requires the docker engine for linux.
This mean that Windows and MacOS users will need to host a linux in some way.
There is no need to use Docker Desktop for that.

To ease the installation of such environment on windows, you may use:
- WSL2 with [docker-devbox-wsl](https://github.com/inetum-orleans/docker-devbox-wsl)
- Vagrant + Virtualbox with [docker-devbox-vagrant](https://github.com/inetum-orleans/docker-devbox-vagrant)

If you decide to go the manual route, you will need:
* Docker with docker compose plugin v2
* GNU Bash >= 4.0
* curl

## Devbox installation environment

```sh
curl -L https://github.com/inetum-orleans/docker-devbox/raw/master/installer | bash
```

You may customize the installation by passing environment variables to the bash command, see the example at the bottom of the [Installation environment variables](#installation-environment-variables) section.

This will install everything required for Docker Devbox, but docker,
docker compose and bash should be installed manually before.

It will also install:
* [Traefik](https://traefik.io/) : A container used to route the network traffic on port 80/443 to the right application. (See the [Configuration with a DNS](#configuration-with-a-dns) section)
* [CFSSL](https://github.com/cloudflare/cfssl) : A container to generate HTTPS certificates for the apps in your docker containers.

Docker Devbox will install [Traefik](https://traefik.io/) in a docker container and binds `tcp/80`,`tcp/443` to host,
so those ports should be available.

Port `tcp/7780` should also be available for CFSSL container (local certificate authority service).

*Installation script may ask for sudo password to install some dependencies, like curl, git and make.*

Open a browser and check that you can navigate to `http://<ip of your devbox>/` you should see the traefik's "404 page not found".

// TODO: write a ddb project that can check if we can navigate to an app on port 1212

# Optional setup
## Configuration with a DNS

Using an IP address like `http://192.168.99.100:1212/` is not very convenient because:
* We need to remember the IP address and the port of our application
* If we need to run multiple applications at the same time, we need to open several ports
* If several devs have different configurations, the IP/Port might not be the same across the team.

It would be better to use a name like `http://myapp.test` and `http://mysecondapp.test`, and be able to call both of them at once.
Even better, sometimes we need apis, and we can call them at `http://api.myapp.test` and share cookies with it because it is a subdomain. You're likely to have that kind of domain hierarchy in prod anyway, and being able to figure out things like CORS locally is really valuable.

Lastly, if you want to let traefik handle the complexity of https certificates ([see next section](#generate-certificates-for-your-applications)) for you and your application, it needs a way to route your request to your app, and the domain name is the easiest way.

[Read on to know how to configure the DNS for your apps](docs/dns.md)

## Generate HTTPS certificates for your applications

More and more websites are using https (if not most), but the same cannot be said of development environments or even QA environments, which are often HTTP because generating valid HTTPS certificates on internal network can be a headache.

However, [more and more features are requiring a Secure Context](https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts/features_restricted_to_secure_contexts).

What if it could be done as easily as:

```bash
ddb configure
dc up -d
```
?

[You just need to install the certificates on your machine :wink:](docs/certs.md)

## Installation environment variables

Environment variables available for installer script:

- Partial installs:
  - `DOCKER_DEVBOX_DISABLE_SMARTCD`: Disable SmartCD.
  - `DOCKER_DEVBOX_DISABLE_CFSSL`: Disable CFSSL.
  - `DOCKER_DEVBOX_DISABLE_PORTAINER`: Disable portainer.
  - `DOCKER_DEVBOX_DISABLE_REVERSE_PROXY`: Disable reverse-proxy feature (traefik).
  - `DOCKER_DEVBOX_DISABLE_OPTIONAL_DEPENDENCIES`: Disable the installation of mkcert.
  - `DOCKER_DEVBOX_MINIMAL`: Creates the required folder, download the `ddb` binary and create reverse-proxy network only.
  Does not install other tools like smartcd, cfssl, portainer, etc.
  - `DOCKER_DEVBOX_CI`: Equivalent to `DOCKER_DEVBOX_MINIMAL` and `DOCKER_DEVBOX_DISABLE_OPTIONAL_DEPENDENCIES`,
    recommanded for CI.
- Specific version installs:
  - `DOCKER_DEVBOX_DDB_VERSION`: Install a specific version of ddb (ex: `v2.0.1`). When unset, gets the latest version
  - `DOCKER_DEVBOX_SMARTCD_BRANCH`: Use a specific [smartcd (inetum fork)](https://github.com/inetum-orleans/smartcd) branch.
  - `DOCKER_DEVBOX_CFSSL_BRANCH`: Use a specific [docker-devbox-cfssl](https://github.com/inetum-orleans/docker-devbox-cfssl) branch.
  - `DOCKER_DEVBOX_PORTAINER_BRANCH`: Use a specific [docker-devbox-portainer](https://github.com/inetum-orleans/docker-devbox-portainer) branch.
  - `DOCKER_DEVBOX_TRAEFIK_BRANCH`: Use a specific [docker-devbox-traefik](https://github.com/inetum-orleans/docker-devbox-traefik) branch.
  - `DOCKER_DEVBOX_DDB_ASSET_NAME`: Custom [ddb release](https://github.com/inetum-orleans/docker-devbox-ddb/releases)
    asset name to install ddb. It was set to "ddb-linux-older-glibc" to install ddb on
    older linux distributions, like Ubuntu 16.04. This asset is not compiled anymore, but the option sticked.
    You should also add this value to `core.release_asset_name` in ddb
    configuration to make `self-update` command download this asset.
- Misc:
  - `DOCKER_DEVBOX_CURL_OPTS_GITHUB_API`: Additional curl options to pass when accessing github api. You can set this
    variable to `-u <username:token>` using a Github Personnal Access Token if you encounter 403 errors due to rate
    limiting.
  - `DOCKER_DEVBOX_SKIP_DOCKER_CHECKS`: Force installation even if `docker` binary is unavailable.
  - `DOCKER_DEVBOX_REVERSE_PROXY_NETWORK`: Name of the reverse proxy network. Default is `reverse-proxy`.
  - `DOCKER_DEVBOX_ALLOW_ROOT`: Allow the script to be run as root. This is not recommended.

Environment variables can be set right before bash invocation in the installer one-liner.

```bash
curl -L https://github.com/inetum-orleans/docker-devbox/raw/master/installer | \
DOCKER_DEVBOX_CI=1 \
bash
```
