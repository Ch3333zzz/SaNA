FROM quay.io/frrouting/frr:10.5.1

USER root

RUN apk add --no-cache bash busybox-extras iptables \
    && adduser -D -G frrvty -s /usr/local/bin/frr-telnet-shell telnetuser \
    && echo 'telnetuser:Huawei@123' | chpasswd

COPY frr-telnet-shell /usr/local/bin/frr-telnet-shell
COPY start-telnet.sh /usr/local/bin/start-telnet.sh

RUN chmod 755 /usr/local/bin/frr-telnet-shell \
              /usr/local/bin/start-telnet.sh

CMD ["/usr/local/bin/start-telnet.sh"]
