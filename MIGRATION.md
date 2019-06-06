Migration
=========

This is a migration document for people using old project skeletons based on a hard-coded `nginx-proxy` network inside 
`docker-compose.override.dev.yml`. Those projects were most commonly generated with 
[generator-docker-devbox](https://github.com/gfi-centre-ouest/generator-docker-devbox) < 1.4.

New projects generated with [generator-docker-devbox](https://github.com/gfi-centre-ouest/generator-docker-devbox) >= 1.4 
can use any of nginx-proxy and traefik as reverse proxy, but requires a local installation of 
[docker-devbox](https://github.com/gfi-centre-ouest/docker-devbox). 

Keep in mind that a single reverse proxy can run at the same time on the host (either nginx-proxy or traefik).

Migrate an existing docker-devbox machine
-----------------------------------------

This is a migration path for a machine that runs docker-devbox projects. This migration path is written to make older 
projects fully compatible. If you don't need to stay compatible with older project, you should perform the normal 
installation procedure from README.md.

- Delete old containers

```bash
docker rm -f nginx-proxy nginx-proxy-fallback portainer
```

- Add system environment variables
[defined here](https://github.com/gfi-centre-ouest/docker-devbox-vagrant/blob/master/config.example.yaml#L11-L18) 
(Could be defined in `.bashrc`, or inside `config.yaml` for [docker-devbox-vagrant](https://github.com/gfi-centre-ouest/docker-devbox-vagrant) users)

- Add environment variable `DOCKER_DEVBOX_REVERSE_PROXY_NETWORK=nginx-proxy`. 
(Could be defined in `.bashrc`, or inside `config.yaml` for [docker-devbox-vagrant](https://github.com/gfi-centre-ouest/docker-devbox-vagrant) users)

- Install [docker-devbox](https://github.com/gfi-centre-ouest/docker-devbox) with `DOCKER_DEVBOX_USE_NGINX_PROXY` environment variable

```bash
curl -L https://github.com/gfi-centre-ouest/docker-devbox/raw/master/installer | DOCKER_DEVBOX_USE_NGINX_PROXY=1 bash
```

- Create symlinks for older project to copy certificates at the right place

```bash
mkdir -p ~/.nginx-proxy
ln -fs ~/.docker-devbox/certs ~/.nginx-proxy/certs
ln -fs ~/.docker-devbox/nginx-proxy/vhost.d ~/.nginx-proxy/vhost.d
```

Migrate a project using docker-devbox-generator > 1.4
-----------------------------------------------------

This is guideline to migrate a project created from a manual template or with 
[generator-docker-devbox](https://github.com/gfi-centre-ouest/generator-docker-devbox) < 1.4

**You must at least perform the following operations.**

- Update version in `docker-compose.yml` and `.override` files, it should be at least `2.2` or `3.7`.

```yaml
version: '2.2'
```

- Look for each declaration of `nginx-proxy` network and replace with the more generic and configurable external network.

Before:
```yaml
networks:
  nginx-proxy:
    external: true
```

Now:
```yaml
networks:
  reverse-proxy:
    name: '${DOCKER_DEVBOX_REVERSE_PROXY_NETWORK}'
    external: true
```

- Look for each usage of `nginx-proxy` network and replace with `reverse-proxy`.

Before:
```yaml
services:
  web:
    networks:
      - nginx-proxy
```

Now:
```yaml
services:
  web:
    networks:
      - reverse-proxy
```

- Look for each occurence of `VIRTUAL_HOST` and add traefik labels with the same values. You could also add 
`VIRTUAL_PORT` if missing.

Before:
```yaml
services:
  web:
    environment:
      - 'VIRTUAL_HOST=${DOCKER_DEVBOX_DOMAIN_PREFIX}.${DOCKER_DEVBOX_DOMAIN}'
```

Now:
```yaml
services:
  web:
    labels:
      - traefik.enable=true
      - 'traefik.frontend.rule=Host:${DOCKER_DEVBOX_DOMAIN_PREFIX}.${DOCKER_DEVBOX_DOMAIN}'
      - traefik.port=80
    environment:
      - 'VIRTUAL_HOST=${DOCKER_DEVBOX_DOMAIN_PREFIX}.${DOCKER_DEVBOX_DOMAIN}'
      - 'VIRTUAL_PORT=80'
```

At this point, the project should work like before with either traefik or nginx-proxy as the reverse-proxy.

**Operations that follows are now optional, but you should consider them to benefits of all features provided by docker-devbox.**

- Run [generator-docker-devbox](https://github.com/gfi-centre-ouest/generator-docker-devbox) inside the project 
directory. You should choose features that match your existing environment.

```bash
yo @gfi-centre-ouest/docker-devbox
``` 

- Override all conflicts, but keep `docker-compose.yml` and `docker-compose.override.dev.yml`.

- Restore your `.gitignore` but keep the generated one content at the top of the file.

- Remove `.bash_enter.env` or `.bash_enter_env` and cleanup `.bash_enter.config`.

- Remove `.bash.lib.d`, `.bash_enter.d` and `.bash_leave.d` directories. Those directories are now read right from 
included locally installed docker-devbox (`~/.docker-devbox/scripts`). You can style bring those directories back if 
you need to override or add a script.

- Remove `dc` `mo` `run` `system` `jq` files from `.bin` directory.

- Rename original `Dockerfile` files from `.docker` subdirectories to `Dockerfile.mo`

- Run `cd .` to reload the environment or run `source .bash_enter`.

- If `.bash_enter` was defining aliases for commands like `php`, `composer`, `npm`, you should create equivalent 
scripts into `.bin` directory. You may play with 
[generator-docker-devbox](https://github.com/gfi-centre-ouest/generator-docker-devbox) by generating dummy projects to 
see how `.bin` script are written.

Here's the `npm` command as an example, replace `{{instance.name}}` with the service name (i.e `node`). 
`_docker_workdir` function can help to map the current working directory into the container.

```bash
#!/usr/bin/env bash
. "$DOCKER_DEVBOX_SCRIPTS_PATH/.bash.lib.d/50-docker"

run --workdir="$(_docker_workdir "/app")" --entrypoint npm {{instance.name}} "$@"
```

- In `.bin` directory, replace `_docker_devbox_map_workdir` with `_docker_workdir` and 
`$DOCKER_DEVBOX_DIR` with `$DOCKER_DEVBOX_SCRIPTS_PATH`.

- In `.docker/**/Dockerfile.mo` files, replace `DOCKER_DEVBOX_CA_CERTIFICATES` with `DOCKER_DEVBOX_COPY_CA_CERTIFICATES`