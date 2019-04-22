#!/bin/bash

echo "Deploying YayPonies IPFS Mirror"
echo ""

which ipfs &> /dev/null || { echo "Install ipfs, first: https://docs.ipfs.io/introduction/install/" && exit 1; }

echo "This script has only been tested on Debian Jessie and Ubuntu Trusty"
echo "It will install a new IPFS mirror on a newly deployed system"
echo "It SHOULD NOT BE USED ON MULTIPLE SITE CONFIGURATION"
echo "IT SHOULD ALSO NOT BE USED IF PORT 8808 IS UNAVAILABLE"
echo ""
echo "This will install nginx from your distribution repository"
echo "set configuration, cron task"
echo "and finally start your mirror"
echo ""
echo "This program is distributed WITHOUT ANY WARRANTY"
read -n1 -r -p "Press space or enter to continue, any other keys to cancel..." key

if [ "$key" = '' ]; then
    echo ""
    echo "OK, Starting..."
else
    echo ""
    echo "OK, Cancelling..."
    exit 1
fi


sudo service nginx stop
sudo rm -rf /etc/nginx/sites-enabled/default
sudo rm -rf /etc/nginx/conf.d/default

HTTP="    server {\n
        listen       8808 default_server;\n
        listen       [::]:8808 default_server;\n
        server_name  localhost;\n
        ssi on;\n
        root         $PWD/ypmirror;\n
        error_page 404 /sorry/404.php;\n
        error_page 403 /sorry/403.php;\n
        autoindex off;\n
        location / {\n
                index index.php index.html index.htm;\n
                error_page 404 /sorry/404.php;\n
                error_page 403 /sorry/403.php;\n
        }\n
        location ~ \.php$ {\n
                types { text/html php; }\n
        }       \n
    }"
echo -e $HTTP > yp.conf
sudo mv yp.conf /etc/nginx/conf.d/yp.conf
sudo service nginx start

./yayponies-update.sh $PWD localhost:8808

crontab -l > /tmp/yayponies-cron
sed -i '/yayponies-update/d' /tmp/yayponies-cron
echo "0 */10 * * * $PWD/yayponies-update.sh $PWD localhost:8808" >> /tmp/yayponies-cron
crontab /tmp/yayponies-cron
rm /tmp/yayponies-cron
