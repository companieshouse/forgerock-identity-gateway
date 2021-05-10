#!/bin/sh

sed "s|{APPLICATION_HOST}|$APPLICATION_HOST|g" /var/ig/config/routes/webfiling.json.tpl > /var/ig/config/routes/webfiling.json

rm /var/ig/config/routes/webfiling.json.tpl

/opt/ig/bin/start.sh /var/ig