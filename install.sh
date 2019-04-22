#!/bin/bash

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
sudo cp script.sh /usr/bin/yayponies-update.sh

yayponies-update.sh $PWD localhost:8808

crontab -l > /tmp/yayponies-cron
sed -i '/yayponies-update/d' /tmp/yayponies-cron
echo "*/10 * * * * /usr/bin/yayponies-update.sh $PWD localhost:8808" >> /tmp/yayponies-cron
crontab /tmp/yayponies-cron
rm /tmp/yayponies-cron
