#!/bin/bash

cp /home/ubuntu/myunit.service /etc/systemd/system/myunit.service
systemctl enable myunit
systemctl -l status myunit
systemctl start myunit
#systemctl -l status myunit
