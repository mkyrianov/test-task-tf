#!/bin/bash

apt update
apt upgrade -y
apt install apache2 -y
systemctl start apache2

echo "Hello World!" > /var/www/html/index.html
