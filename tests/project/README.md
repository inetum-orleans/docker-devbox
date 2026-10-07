docker-devbox test project
==========================

A minimal docker-devbox project used by the `Test` workflow to check that a real project gets a working
TLS certificate from the installed devbox.

`ddb.VirtualHost` exposes the `traefik/whoami` container as `devbox-test.test`, which makes ddb emit a
`certs:generate` event. CFSSL then issues the certificate into `.certs`, and traefik installs it in
`~/.docker-devbox/certs` along with a `~/.docker-devbox/traefik/config/devbox-test.test.ssl.toml`
configuration file.

To run it manually against an installed devbox:

```
ddb configure
docker compose up -d
curl --cacert <cfssl-ca.pem> --resolve devbox-test.test:443:127.0.0.1 https://devbox-test.test/
```

The CA certificate can be extracted from the CFSSL container:

```
cd ~/.docker-devbox/cfssl && docker compose cp intermediate:/etc/cfssl/ca.pem ca.pem
```
