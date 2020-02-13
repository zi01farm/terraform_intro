#!/bin/bash

cd /home/ubuntu/app
sudo export DB_HOST=${db_host}
sudo npm install
node app.js
