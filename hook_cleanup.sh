#!/bin/bash

RESULT=$(curl -s "https://www.duckdns.org/update?domains=${CERTBOT_DOMAIN}&token=${DUCKDNS_TOKEN}&txt=")
if [[ "${RESULT}" != "OK" ]] ; then
        echo "Failed to clean TXT record"
        echo "${RESULT}"
        exit 2
fi
exit 0
