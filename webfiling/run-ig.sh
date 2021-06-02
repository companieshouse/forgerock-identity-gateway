#!/bin/sh

sed -e "s|{APPLICATION_HOST}|$APPLICATION_HOST|g" /var/ig/config/routes/100-webfiling.json.tpl > /var/ig/config/routes/100-webfiling.json
sed -e "s|{APPLICATION_HOST}|$APPLICATION_HOST|g" /var/ig/config/routes/static-resources.json.tpl > /var/ig/config/routes/static-resources.json

rm /var/ig/config/routes/100-webfiling.json.tpl
rm /var/ig/config/routes/static-resources.json.tpl

/opt/ig/bin/start.sh /var/ig