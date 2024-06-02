#!/bin/sh

if [ ! -e /data/data/server.json ]
then
    echo -ne "0.0.0.0\r\n8001\r\nsnac2.test\r\n\r\n\r\n" | snac init /data/data
else
    # Update the host field in server.json
    jq '.host = "snac2.test"' /data/data/server.json > /tmp/server.json && mv /tmp/server.json /data/data/server.json
fi

if [ ! -e /data/data/user/testuser ]
then
    rm -r /data/data/user/testuser
fi

if [ ! -e /data/data/user/user2a ]
then
    snac adduser /data/data user2a
fi

SSLKEYLOGFILE=/data/key snac httpd /data/data

