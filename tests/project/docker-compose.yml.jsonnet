local ddb = import 'ddb.docker.libjsonnet';

local domain_ext = std.extVar("core.domain.ext");
local domain_sub = std.extVar("core.domain.sub");

local domain = std.join('.', [domain_sub, domain_ext]);

ddb.Compose() + {
   services: {
      web: ddb.Image("traefik/whoami") + ddb.VirtualHost(80, domain)
   }
}
