#!/bin/bash
set -euo pipefail

/usr/sbin/telnetd -F -b 0.0.0.0 -p 23 -l /bin/login &
exec /usr/lib/frr/docker-start
