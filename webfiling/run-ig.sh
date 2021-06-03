#!/bin/sh

sed -e "s|{APPLICATION_HOST}|$APPLICATION_HOST|g" -e "s|{APPLICATION_IP}|$APPLICATION_IP|g" /var/ig/config/routes/01-webfiling-default.json.tpl > /var/ig/config/routes/01-webfiling-default.json
sed -e "s|{APPLICATION_HOST}|$APPLICATION_HOST|g" -e "s|{APPLICATION_IP}|$APPLICATION_IP|g" /var/ig/config/routes/10-webfiling-seclogin.json.tpl > /var/ig/config/routes/10-webfiling-seclogin.json

rm /var/ig/config/routes/*.tpl

/opt/ig/bin/start.sh /var/ig