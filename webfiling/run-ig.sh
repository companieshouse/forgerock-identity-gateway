#!/bin/sh

sed -e "s|{APPLICATION_HOST}|$APPLICATION_HOST|g" -e "s|{APPLICATION_IP}|$APPLICATION_IP|g" /var/ig/config/routes/10-webfiling-seclogin.json.tpl > /var/ig/config/routes/10-webfiling-seclogin.json

/opt/ig/bin/start.sh /var/ig