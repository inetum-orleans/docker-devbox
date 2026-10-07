docker-devbox-cfssl
===================

CFSSL docker-compose configuration to use with docker-devbox.

It allows to generate certificates from a 3 level chain (Root CA, Intermediate CA, End-User CA)

The image is built from `.docker/cfssl`, which compiles [CFSSL](https://github.com/cloudflare/cfssl) at the version
pinned by the `CFSSL_VERSION` build argument and initializes the certificate authority on first start. Its entrypoint
and certificate authority bootstrap scripts are Apache 2.0, Copyright LasLabs Inc., as stated in their headers.

Installation
------------
```
docker compose up --build
```

Validity periods
----------------

Certificates are issued for a long time, as they only ever serve local development:

| Certificate | Configured in | Validity |
| --- | --- | --- |
| Root CA | `.docker/cfssl/etc/csr_root_ca.json` | 23 years |
| Intermediate CA | `.docker/cfssl/etc/csr_intermediate_ca.json` | 23 years |
| Project certificate | `.docker/cfssl/etc/ca_intermediate_config.json` | 20 years |

They are kept below a quarter of a century so that, for the time being, expiry dates stay under 2050 and are therefore
encoded as `UTCTime` rather than `GeneralizedTime`
([RFC 5280 4.1.2.5](https://datatracker.ietf.org/doc/html/rfc5280#section-4.1.2.5)). That is the convention public
certificate authorities follow, and nothing more: since the durations are relative to the issuance date, an installation
made after 2027 crosses 2050 anyway, and current TLS stacks read `GeneralizedTime` just fine.

Changing these values only affects certificates issued afterwards. `ddb configure` regenerates a project certificate
when it is missing, never when it expired or when the configuration changed, and the certificate authority itself lives
in a docker volume that survives reinstallations. To issue a brand new certificate authority with the current durations,
reinstall docker-devbox with `DOCKER_DEVBOX_RESET=1`.

Then, in each project, remove the `.certs` directory and run `ddb configure` again. The new root certificate has to be
installed in the client trust store, as described in the docker-devbox README.

Generate a wildcard certificate for a domain name
--------------------------------------------------
- From server shell

```
dc exec intermediate sh
H=eqo.app # Domaine name of the certificate
cfssl gencert -ca ca.pem -ca-key ca-key.pem -hostname "$H,*.$H" ca_intermediate_config.json | cfssljson -bare "$H"
cat ca.pem >> "$H.pem"
exit
```

- From REST API with [cfssl-cli](https://github.com/Toilal/python-cfssl-cli)

Get the root certificate to add to client truststore
----------------------------------------------------
- From server shell

```
dc exec root cat /etc/cfssl/ca.pem
```
