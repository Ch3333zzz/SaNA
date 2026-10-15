FROM quay.io/frrouting/frr:10.5.1

USER root

RUN apk add --no-cache dnsmasq busybox iproute2 \
    && command -v dnsmasq \
    && command -v udhcpc \
    && command -v ip

