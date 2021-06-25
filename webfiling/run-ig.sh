#!/bin/sh

sed -e "s|{APPLICATION_HOST}|$APPLICATION_HOST|g" -e "s|{APPLICATION_IP}|$APPLICATION_IP|g" /var/ig/config/routes/10-webfiling.json.tpl > /var/ig/config/routes/10-webfiling.json
sed -e "s|{APPLICATION_HOST}|$APPLICATION_HOST|g" -e "s|{APPLICATION_IP}|$APPLICATION_IP|g" /var/ig/config/routes/01-legacy.json.tpl > /var/ig/config/routes/01-legacy.json

/opt/ig/bin/start.sh /var/ig