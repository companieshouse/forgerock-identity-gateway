#!/bin/sh

sed -e "s|{APPLICATION_HOST}|$APPLICATION_HOST|g" -e "s|{APPLICATION_IP}|$APPLICATION_IP|g" /var/ig/config/routes/webfiling.json.tpl > /var/ig/config/routes/webfiling.json

rm /var/ig/config/routes/webfiling.json.tpl

/opt/ig/bin/start.sh /var/ig