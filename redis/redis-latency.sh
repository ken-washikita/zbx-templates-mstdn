#!/bin/bash

WORKFILE=/var/tmp/redis-latency
SAVEFILE=/etc/zabbix/redis/redis-latency

redis-cli --latency > $WORKFILE &
pid=$!
sleep 5
kill -9 $pid
sed -e 's/.*max: //' -e 's/,.*/\
/' <$WORKFILE >$SAVEFILE
