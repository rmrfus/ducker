#!/bin/bash

RESULT=$(curl -s "https://www.duckdns.org/update?domains=${CERTBOT_DOMAIN}&token=${DUCKDNS_TOKEN}&txt=${CERTBOT_VALIDATION}")
if [[ "${RESULT}" != "OK" ]] ; then
        echo "Failed to set TXT record"
        echo "${RESULT}"
        exit 2
fi

# TTL of TXT records is 60 seconds...
sleep 61

exit 0
