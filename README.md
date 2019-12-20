# Ducker

This set of scripts allow to periodically renew DuckDNS IP, painlessly obtain cert for primary DuckDNS domain AND wildcard domain in the same cert and renew it if needed. It is designed to be run in Docker, but nobody prevents you to use it without it.

*DISCLAIMER: This is very raw set of scripts written overnight and still in testing phase*

### TL;DR

```
git clone https://github.com/rmrfus/ducker
cd ducker
docker build -t ducker:latest .
docker run --name ducker --restart always \
    -v /opt/letsencrypt:/etc/letsencrypt \
    -e DUCKDNS_DOMAIN=[put your duckdns FQDN here (i.e. mycool.duckdns.org)] \
    -e DUCKDNS_TOKEN=[put your duckdns token here] \
    -e ACME_EMAIL=[email for letsencrypt notifications] \
    ducker
```

### Long story

All recipies in the internets didn't work. Any flavor of letsencrypt client (except Traefik) attempted to run two DNS challenges sequentially and miserably fail because DuckDNS cannot keep two TXT records at the same time.
The trick is to obtain cert for primary domain, for example `mycool.duckdns.org` and then extend it to `mycool.duckdns.org,*.mycool.duckdns.org`.
