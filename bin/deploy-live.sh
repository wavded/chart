#!/bin/sh

echo "\033[36mchart:\033[m copying files to \033[36m'live'\033[m";

rsync -az --exclude=".git" --exclude='node_modules' --delete * ubox1:/var/www/chart

echo "\033[36mchart:\033[m updating npm packages on \033[36m'live'\033[m";
echo "---"
ssh ubox1 "cd /var/www/chart/ && npm install"
echo "---"

echo "\033[36mchart:\033[m restarting node app on \033[36m'live'\033[m";

ssh -t ubox1 sudo restart chart

echo "\033[36;1mchart:\033[m app running on \033[36;1m'live'\033[m";
