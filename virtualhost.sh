#!/usr/bin/env bash

block="<VirtualHost *:$3>
    ServerName $1
    DocumentRoot $2
    ServerAlias $1
</VirtualHost>

"
echo "$block" > "/etc/httpd/sites-available/$1.conf"
ln -fs "/etc/httpd/sites-available/$1.conf" "/etc/httpd/sites-enabled/$1.conf"
apachectl restart