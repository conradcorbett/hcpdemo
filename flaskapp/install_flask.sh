#!/bin/bash
set -ex

sudo hostnamectl set-hostname cc-tf-flaskapp
sudo systemctl stop firewalld

sudo yum install python3 python3-devel mysql-devel gcc -y
pip3 install -r /root/flaskapp/requirements.txt
#python3 app.py