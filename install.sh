#!/bin/bash
[ $(id -u) -ne 0 ] { echo "This script has to be run as root"; exit 1; }

service nginx stop
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/conf.d/default

HTTP="    server {\n
        listen       80 default_server;\n
        listen       [::]:80 default_server;\n
        server_name  $DOMAIN;\n
        ssi on;\n
        root         $PWD/yay;\n
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
echo -e $HTTP > /etc/nginx/conf.d/yp.conf
service nginx start

co script.sh /usr/bin/yayponies-update.sh
crontab -l > /tmp/yayponies-cron
echo "*/10 * * * * /usr/bin/yayponies-update.sh $PWD localhost:8808" >> /tmp/yayponies-cron
crontab /tmp/yayponies-cron
rm /tmp/yayponies-cron
