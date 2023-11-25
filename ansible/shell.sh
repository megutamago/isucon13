#!/bin/bash
set -eux

git pull

# sql init
sudo mysql -u isucon -pisucon -e "DROP DATABASE IF EXISTS isupipe"
sudo mysql -u isucon -pisucon -e "CREATE DATABASE IF NOT EXISTS isupipe"
sudo cat ~/webapp/sql/initdb.d/10_schema.sql | sudo mysql isupipe
~/webapp/sql/init.sh

# app init
sudo systemctl restart isupipe-go
sudo rm -f /var/log/nginx/access.log
sudo systemctl restart nginx
sudo rm -f /var/log/mysql/mysql-slow.sql
sudo systemctl restart mysql
