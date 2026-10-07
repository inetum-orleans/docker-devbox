local ddb = import 'ddb.docker.libjsonnet';

local pp = std.extVar("jsonnet.docker.expose.port_prefix");
local chain = std.extVar("project.chain");
local compose_network_name = std.extVar("docker.compose.network_name");
local domain_ext = std.extVar("core.domain.ext");
local domain_sub = std.extVar("core.domain.sub");

local domain = std.join('.', [domain_sub, domain_ext]);

ddb.Compose() {
  services: {
    intermediate: ddb.Build("cfssl") +
                  ddb.VirtualHost(80, domain) + {
      environment+: [
        "CFSSL_CSR=csr_intermediate_ca.json",
        "CFSSL_CONFIG=ca_intermediate_config.json"
      ] + if chain then ["CA_ROOT_URI=http://root." + compose_network_name] else [],
      ports: [pp + "80:80"],
      expose: [80],
      [if chain then "depends_on"]: ["root"],
      volumes+: [
        "intermediate:/etc/cfssl",
        "intermediate_trust:/cfssl_trust"
      ]
    },
    [if chain then "root"]: ddb.Build("cfssl") + {
      environment+: [
        "CFSSL_CSR=csr_root_ca.json",
        "CFSSL_CONFIG=ca_root_config.json"
      ],
      volumes+: [
        "root:/etc/cfssl",
        "root_trust:/cfssl_trust"
      ]
    }
  }
}