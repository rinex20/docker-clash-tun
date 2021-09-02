FROM dreamacro/clash-premium:latest

COPY entrypoint.sh /usr/local/bin/

RUN apk add --no-cache \
    ca-certificates  \
    bash  \
    curl \
    ipset \
    iptables  \
    bash-doc  \
    bash-completion  \
    rm -rf /var/cache/apk/* && \
    chmod a+x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/clash"]
CMD ["/usr/local/bin/entrypoint.sh"]
