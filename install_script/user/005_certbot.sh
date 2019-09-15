#!/bin/sh

cd /usr/local && git clone https://github.com/certbot/certbot
cd /usr/local/certbot && ./certbot-auto certonly --standalone -t
