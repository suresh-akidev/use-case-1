#!/bin/bash
yum update 
yum -y install docker
service docker start
usermod -a -G docker ec2-user 
chkconfig docker on 
pip3 install docker-compose
sudo apt install unzip -y
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
reboot