# Ducker

This set of scripts allow to periodically renew DuckDNS IP, painlessly obtain
ONE cert for primary and wildcard DuckDNS domain and renew it over time as needed.
It is designed to be run in Docker, but nobody prevents you to use it without it.

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
    -e ACME_TEST=YES \
    ducker
```

If everything looks sane, delete exported volume (`/opt/letsencrypt` in this example) and run same command without `ACME_TEST=YES` to request valid certificates.

### Long story

All recipies in the internets didn't work. Any flavor of letsencrypt client
(except Traefik) attempted to run two DNS challenges sequentially and miserably
fail because DuckDNS cannot keep two TXT records at the same time.
Of course you can maintain 2 different certs -- one for primary domain and one for wildcard, but this is just not fair.

The trick is to obtain cert for primary domain, for example `mycool.duckdns.org` and then extend it to `mycool.duckdns.org,*.mycool.duckdns.org`. This way cert will contain SANs for both domains.

### Notes

- Initial run of script will request both certs if needed. Otherwise it will attempt to renew them daily.
- Because DuckDNS TXT record has TTL equal to 60 seconds `hook_auth.sh` will sleep 60 seconds before continue. Be patient.
- It is recommended to check if you got proper SANs in cert by running `openssl x509 -in cert.pem -text | grep DNS` as root from proper directory.
