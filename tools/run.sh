#!/bin/bash

name="$NAME"
url="$URL"


sed -i "s;\[\[name\]\];$name;g" \
 /app/config/config.xml

sed -i "s;\[\[url\]\];$url;g" \
 /app/config/capture.xml  


cd /app
exec ./bin/kerberos
