#!/bin/sh

if [ ! -e /data/data/server.json ]
then
    echo -ne "0.0.0.0\r\n8001\r\nsnac1.test\r\n\r\n\r\n" | snac init /data/data
else
    # Update the host field in server.json
    jq '.host = "snac1.test"' /data/data/server.json > /tmp/server.json && mv /tmp/server.json /data/data/server.json
fi

if [ ! -e /data/data/user/testuser ]
then
    rm -r /data/data/user/testuser
fi

if [ ! -e /data/data/user/user1a ]
then
    snac adduser /data/data user1a
fi

if [ ! -e /data/data/user/user1b ]
then
    snac adduser /data/data user1b
fi

SSLKEYLOGFILE=/data/key snac httpd /data/data

