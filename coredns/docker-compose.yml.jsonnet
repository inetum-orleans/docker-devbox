local ddb = import 'ddb.docker.libjsonnet';

local pp = std.extVar("docker.port_prefix");
local compose_network_name = std.extVar("docker.compose.network_name");
local domain_ext = std.extVar("core.domain.ext");
local domain_sub = std.extVar("core.domain.sub");

local domain = std.join('.', [domain_sub, domain_ext]);

ddb.Compose() {
    services: {
        coredns: ddb.Build('coredns') + {
            expose: [
                "53",
                "53/udp"
            ],
            ports: [
                "53:53",
                "53:53/udp"
            ],
            volumes: [
                ddb.path.project + "/config:/etc/coredns"
            ]
        }
    }
}