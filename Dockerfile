FROM alpine

VOLUME /etc/letsencrypt

COPY ducker.sh hook_auth.sh hook_cleanup.sh /ducker/

RUN chmod +x /ducker/*.sh && \
    apk update && \
    apk add bash certbot coreutils curl && \
    rm /var/cache/apk/APKINDEX.*

CMD ["/bin/bash", "/ducker/ducker.sh"]
