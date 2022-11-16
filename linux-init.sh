#!/usr/bin/bash

# 安装mssql
sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/7/mssql-server-2019.repo
sudo yum install -y mssql-server

#   安装SVN
sudo yum install -y subversion

#   获取Node并安装
sudo curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install nodejs -y
sudo npm install npm@latest -g
sudo npm i -g typescript

#   获取Minio并安装
sudo yum install wget -y && sudo wget https://dl.min.io/server/minio/release/linux-amd64/minio
sudo chmod +x minio
sudo wget https://dl.min.io/client/mc/release/linux-amd64/mc
sudo chmod +x mc

#   获取宝塔并安装
sudo yum install -y wget && wget -O install.sh http://download.bt.cn/install/install_6.0.sh && sh install.sh

