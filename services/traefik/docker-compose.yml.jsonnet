local ddb = import 'ddb.docker.libjsonnet';

local pp = std.extVar("jsonnet.docker.expose.port_prefix");
local compose_network_name = std.extVar("docker.compose.network_name");
local domain_ext = std.extVar("core.domain.ext");
local domain_sub = std.extVar("core.domain.sub");
local dashboard_enabled = std.extVar("traefik_dashboard.enabled");

local domain = std.join('.', [domain_sub, domain_ext]);

ddb.Compose() {
  services: {
      traefik: ddb.Image("traefik:3.7") + {
         container_name: "traefik",
         ports+: [
            "80:80",
            "443:443"
         ],
         networks+: [
            "default",
            "reverse-proxy"
         ],
         labels+: if dashboard_enabled then
            {
               "traefik.enable": true,
               "traefik.http.routers.traefik-dashboard.rule": "Host(`" + domain + "`)",
               "traefik.http.routers.traefik-dashboard.service": "api@internal",
               "traefik.http.routers.traefik-dashboard-localhost.rule": "Host(`localhost`) || Host(`127.0.0.1`)",
               "traefik.http.routers.traefik-dashboard-localhost.service": "api@internal",
               "ddb.emit.certs:generate[localhost]": "localhost",
               "ddb.emit.certs:generate[127.0.0.1]": "127.0.0.1",
               "traefik.http.routers.traefik-dashboard-tls.rule": "Host(`" + domain + "`)",
               "traefik.http.routers.traefik-dashboard-tls.service": "api@internal",
               "traefik.http.routers.traefik-dashboard-tls.tls": true,
               "traefik.http.routers.traefik-dashboard-tls-localhost.rule": "Host(`localhost`) || Host(`127.0.0.1`)",
               "traefik.http.routers.traefik-dashboard-tls-localhost.service" :"api@internal",
               "traefik.http.routers.traefik-dashboard-tls-localhost.tls": "true"
            } + ddb.TraefikCertLabels(domain, "traefik-dashboard")
         else {},
         volumes+: [
            "/var/run/docker.sock:/var/run/docker.sock",
            ddb.path.project + "/.docker/.ca-certificates:/ca-certs",
            ddb.path.project + "/traefik.toml:/traefik.toml",
            ddb.path.project + "/acme.json:/acme.json",
            ddb.path.project + "/config:/config",
            ddb.path.home + "/certs:/certs"
         ]
      }
   }
}
