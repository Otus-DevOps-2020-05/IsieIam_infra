#!/bin/bash

sudo apt install -y git
sudo apt install -y mc

su ubuntu
cd /home/ubuntu
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
#puma -d
