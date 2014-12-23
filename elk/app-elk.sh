#!/bin/sh

[ -f /app/.init ] || ( /app/elk-init.sh && touch /app/.init )

service rsyslog start

/usr/bin/supervisord -n

exit 0
