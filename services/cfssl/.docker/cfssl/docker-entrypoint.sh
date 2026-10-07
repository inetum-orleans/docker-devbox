#!/bin/sh
# Copyright 2016-2017 LasLabs Inc.
# License Apache 2.0 (https://www.apache.org/licenses/LICENSE-2.0.html).

set -e

if [ ! -f /etc/cfssl/ca.pem ] || [ ! -f /etc/cfssl/ca-key.pem ]; then
    if [ -z "${CA_ROOT_URI}" ]; then
        init-ca-root
    else
        init-ca-intermediate
    fi
fi

if [ "${1}" = 'cfssl' ]; then
    set -- "$@" -config="/etc/cfssl/${CFSSL_CONFIG}"
fi

exec "$@"
