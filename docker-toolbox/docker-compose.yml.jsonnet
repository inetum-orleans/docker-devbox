local ddb = import 'ddb.docker.libjsonnet';

local pp = std.extVar("docker.port_prefix");
local compose_network_name = std.extVar("docker.compose.network_name");
local domain_ext = std.extVar("core.domain.ext");
local domain_sub = std.extVar("core.domain.sub");

local domain = std.join('.', [domain_sub, domain_ext]);
local traefik_domain = std.join('.', ["traefik", domain_ext]);
local cfssl_domain = std.join('.', ["cfssl", domain_ext]);
local portainer_domain = std.join('.', ["portainer", domain_ext]);

local cfssl_chain = std.extVar("project.cfssl.chain");

ddb.Compose({
    services: {
        [if std.extVar('project.coredns.enabled') then "coredns"]:
            ddb.Build('coredns')
            + {
                expose: [
                    "53",
                    "53/udp"
                ],
                ports: [
                    "53:53",
                    "53:53/udp"
                ],
                volumes: [
                    ddb.path.project + "/.docker/coredns/config:/etc/coredns"
                ]
            },
        [if std.extVar('project.portainer.enabled') then "portainer"]:
            ddb.Image("portainer/portainer")
            + ddb.VirtualHost(9000, portainer_domain, "portainer")
            + {
                command: "-H unix:///var/run/docker.sock --no-auth",
                volumes: [
                    "/var/run/docker.sock:/var/run/docker.sock",
                    "portainer:/data"
                ]
            },
        [if std.extVar("project.traefik.enabled") then "traefik"]:
            ddb.Image("traefik:cantal")
            + {
                ports+: [
                    "80:80",
                    "443:443"
                ],
                networks+: [
                    "default",
                    "reverse-proxy"
                ],
                labels+: {
                    "traefik.enable": true,
                    "traefik.http.routers.traefik-dashboard.rule": "Host(`" + traefik_domain + "`)",
                    "traefik.http.routers.traefik-dashboard.service": "api@internal",
                    "traefik.http.routers.traefik-dashboard-localhost.rule": "Host(`localhost`, `127.0.0.1`)",
                    "traefik.http.routers.traefik-dashboard-localhost.service": "api@internal",
                    "ddb.emit.certs:generate[localhost]": "localhost",
                    "ddb.emit.certs:generate[127.0.0.1]": "127.0.0.1",
                    "traefik.http.routers.traefik-dashboard-tls.rule": "Host(`" + traefik_domain + "`)",
                    "traefik.http.routers.traefik-dashboard-tls.service": "api@internal",
                    "traefik.http.routers.traefik-dashboard-tls.tls": true,
                    "traefik.http.routers.traefik-dashboard-tls-localhost.rule": "Host(`localhost`, `127.0.0.1`)",
                    "traefik.http.routers.traefik-dashboard-tls-localhost.service" :"api@internal",
                    "traefik.http.routers.traefik-dashboard-tls-localhost.tls": "true"
                } + ddb.TraefikCertLabels(traefik_domain, "traefik-dashboard-tls"),
                volumes+: [
                    "/var/run/docker.sock:/var/run/docker.sock",
                    ddb.path.project + "/.docker/.ca-certificates:/ca-certs",
                    ddb.path.project + "/.docker/traefik/config/traefik.toml:/traefik.toml",
                    ddb.path.project + "/.docker/traefik/config/acme.json:/acme.json",
                    ddb.path.project + "/.docker/traefik/hosts:/config",
                    ddb.path.home + "/certs:/certs"
                ]
            },
        [if std.extVar('project.cfssl.enabled') then "cfssl-intermediate"]:
            ddb.Image("gficentreouest/alpine-cfssl")
            + ddb.VirtualHost(80, cfssl_domain, "cfssl-intermediate")
            + {
                environment+: [
                    "CFSSL_CSR=csr_intermediate_ca.json",
                    "CFSSL_CONFIG=ca_intermediate_config.json",
                    "DB_DISABLED=1"
                ] + if cfssl_chain then ["CA_ROOT_URI=http://root." + compose_network_name] else [],
                ports: [pp + "80:80"],
                expose: [80],
                [if cfssl_chain then "depends_on"]: ["root"],
                volumes+: [
                    "intermediate:/etc/cfssl",
                    "intermediate_trust:/cfssl_trust"
                ]
            },
        [if std.extVar('project.cfssl.enabled') && cfssl_chain then "cfssl-root"]:
            ddb.Image("gficentreouest/alpine-cfssl")
            + {
                environment+: [
                    "CFSSL_CSR=csr_root_ca.json",
                    "CFSSL_CONFIG=ca_root_config.json",
                    "DB_DISABLED=1"
                ],
                volumes+: [
                    "root:/etc/cfssl",
                    "root_trust:/cfssl_trust"
                ]
            }
    }
})