#!/bin/bash

DUCKDNS_DOMAIN=${DUCKDNS_DOMAIN:?Please set DUCKDNS_DOMAIN variable}
DUCKDNS_TOKEN=${DUCKDNS_TOKEN:?Please set DUCKDNS_TOKEN variable}
ACME_EMAIL=${ACME_EMAIL:?Please set ACME_EMAIL variable}
ACME_STAGING=${ACME_TEST:+--staging}

INTERVAL_IP=${INTERVAL_IP:-5 minutes}
INTERVAL_CERT=${INTERVAL_CERT:-1 day}

PATH="/ducker:${PATH}"

# -- no serviceable parts below --

export DUCKDNS_TOKEN

FLAG_IP=$(mktemp)
FLAG_CERT=$(mktemp)
FLAG_TEST=$(mktemp)
touch -d '-1 year' "${FLAG_IP}" "${FLAG_CERT}"

#trap 'rm "${FLAG_IP}" "${FLAG_CERT}" "${FLAG_TEST}"; exit 1' SIGTERM SIGINT SIGQUIT 

function renew_ip() {
    echo "RENEWING IP. (KO - means fail)"
    curl -s "https://www.duckdns.org/update/${DUCKDNS_DOMAIN}/${DUCKDNS_TOKEN}"
    echo
}

function renew_cert() {
    echo "RENEWING CERT"
    certbot renew
}

function get_cert() {
    # It is impossible to set 2 TXT records for DuckDNS
    # So the only possible method is to get cert for primary domain
    # and then expand it to wildcard.
    CERTBOT_COMMAND="
        certbot certonly --manual ${ACME_STAGING} \
            --email ${ACME_EMAIL} \
            --no-eff-email \
            --manual-public-ip-logging-ok \
            --agree-tos \
            --preferred-challenges dns \
            --keep \
            --manual-auth-hook hook_auth.sh \
            --manual-cleanup-hook hook_cleanup.sh \
            --max-log-backups 30 \
    "
    echo "=== Obtaining primary certificate ==="
    ${CERTBOT_COMMAND} -d "${DUCKDNS_DOMAIN}"
    echo "=== Obtaining wildcard certificate ==="
    ${CERTBOT_COMMAND} -d "${DUCKDNS_DOMAIN}"',*.'"${DUCKDNS_DOMAIN}" --expand

    # no need to trigger renew for a while
    touch -d "+${INTERVAL_CERT}" "${FLAG_CERT}"
}

# if we don't have proper cert - get it!
certbot certificates -d "${DUCKDNS_DOMAIN},"'*'".${DUCKDNS_DOMAIN}" | grep -q "${DUCKDNS_DOMAIN}" || get_cert

# Main loop. Adjust "touch" times if needed
while true; do
    touch "${FLAG_TEST}"
    if [[ "${FLAG_IP}" -ot "${FLAG_TEST}" ]] ; then
        echo "=== $(date) ==="
        renew_ip
        touch -d "+${INTERVAL_IP}" "${FLAG_IP}"
    fi
    if [[ "${FLAG_CERT}" -ot "${FLAG_TEST}" ]] ; then
        echo "=== $(date) ==="
        renew_cert
        touch -d "+${INTERVAL_CERT}" "${FLAG_CERT}"
    fi
    sleep 10
done

