#!/usr/bin/bash

#   定义nvm版本变量
nvm_version=0.39.3

#   检查服务是否安装
checkInstalled() {
    if ! $1 >/dev/null 2>&1; then
        echo -e "\033[31m未安装$1\033[0m"
        return 0
    else
        echo -e "\033[32m已安装$1\033[0m"
    fi
    return 1
}

#   nvm检查和安装
if checkInstalled nvm; then
    echo -e '\033[32m正在安装nvm\033[0m'
    #   获取NVM并安装
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh" | bash
fi

#   node检查和安装
if checkInstalled node; then
    echo -e '\033[31m正在安装Node\033[0m'
    nvm install 16.19.0
fi

#   svn检查和安装
if checkInstalled svn; then
    echo -e '\033[31m正在安装SVN\033[0m'
    sudo yum install -y subversion
fi

#   mysql检查和安装
if checkInstalled mysql; then
    echo -e '\033[31m正在安装Mysql\033[0m'
fi

#   minio检查和安装
if checkInstalled minio; then
    echo -e '\033[32m正在安装Minio\033[0m'
    wget https://dl.min.io/server/minio/release/darwin-amd64/minio
    chmod +x minio
fi

#   宝塔检查和安装
if echeckInstalled baota; then
    wget -O install.sh http://download.bt.cn/install/install_6.0.sh && sh install.sh
fi
