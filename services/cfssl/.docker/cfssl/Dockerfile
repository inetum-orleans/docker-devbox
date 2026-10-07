# Copyright 2016-2017 LasLabs Inc.
# License Apache 2.0 (https://www.apache.org/licenses/LICENSE-2.0.html).

ARG GOLANG_VERSION=1.26-alpine
ARG ALPINE_VERSION=3.23

FROM golang:${GOLANG_VERSION} AS build

ARG CFSSL_VERSION=v1.6.5

RUN apk add --no-cache git \
 && go install -ldflags "-X github.com/cloudflare/cfssl/cli/version.version=${CFSSL_VERSION#v}" \
      "github.com/cloudflare/cfssl/cmd/cfssl@${CFSSL_VERSION}" \
 && go install "github.com/cloudflare/cfssl/cmd/cfssljson@${CFSSL_VERSION}" \
 && go install "github.com/cloudflare/cfssl/cmd/mkbundle@${CFSSL_VERSION}"

FROM alpine:${ALPINE_VERSION}

ENV CFSSL_CSR="csr_root_ca.json" \
    CFSSL_CONFIG="ca_root_config.json"

COPY --from=build /go/bin/cfssl /go/bin/cfssljson /go/bin/mkbundle /usr/bin/
COPY bin/ /usr/local/bin/
COPY etc/ /etc/cfssl/
COPY docker-entrypoint.sh /

RUN apk add --no-cache curl jq libcap \
 && addgroup -S cfssl \
 && adduser -S -G cfssl cfssl \
 && mkdir -p /cfssl_trust \
 && chmod 755 /docker-entrypoint.sh /usr/local/bin/init-ca-root /usr/local/bin/init-ca-intermediate \
 && chown -R cfssl:cfssl /etc/cfssl /cfssl_trust \
 && chmod 770 /etc/cfssl \
 && chmod 644 /etc/cfssl/*.json \
 && setcap 'cap_net_bind_service=+ep' /usr/bin/cfssl \
 && apk del libcap

USER cfssl:cfssl

WORKDIR /etc/cfssl

VOLUME ["/etc/cfssl", "/cfssl_trust"]
EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["cfssl", \
     "serve", \
     "-address=0.0.0.0", \
     "-ca=/etc/cfssl/ca.pem", \
     "-ca-key=/etc/cfssl/ca-key.pem", \
     "-port=80"]
