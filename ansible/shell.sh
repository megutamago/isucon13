#!/bin/bash
set -eu

git pull

# sql init
mysql -u isucon -pisucon isupipe -e "DROP DATABASE isupipe"
mysql -u isucon -pisucon isupipe -e "CREATE DATABASE isupipe"
cat webapp/sql/initdb.d/10_schema.sql | sudo mysql isupipe
~/webapp/sql/init.sh

# app init
sudo systemctl restart isupipe-go
sudo rm -f /var/log/nginx/access.log
sudo systemctl restart nginx
sudo rm -f /var/log/mysql/mysql-slow.sql
sudo systemctl restart mysql
