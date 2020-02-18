#!/bin/bash
sudo su
apt-get -y update && apt-get -y upgrade
add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
apt-get -y install gdebi python-pip ruby wget
cd /home/ubuntu
wget https://aws-codedeploy-us-east-2.s3.us-east-2.amazonaws.com/latest/install
chmod +x ./install
./install auto
service codedeploy-agent start
