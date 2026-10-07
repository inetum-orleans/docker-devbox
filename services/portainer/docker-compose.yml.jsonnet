local ddb = import 'ddb.docker.libjsonnet';

local domain_ext = std.extVar("core.domain.ext");
local domain_sub = std.extVar("core.domain.sub");

local domain = std.join('.', [domain_sub, domain_ext]);

ddb.Compose() + {
   services: {
      portainer: ddb.Image("portainer/portainer-ce:lts") + ddb.VirtualHost(9000, domain) {
         container_name: "portainer",
         command: "-H unix:///var/run/docker.sock",
         volumes: [
            "/var/run/docker.sock:/var/run/docker.sock",
            "portainer:/data"
         ]
      }
   }
}
