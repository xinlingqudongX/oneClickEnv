#!/usr/bin/bash

#   定义nvm版本变量
nvm_version=0.39.3
#   定义当前目录路径
current_dir=$(pwd)
#   定义当前Node版本
current_node_version=16
#   定义当前系统版本
centos_release=$(cut -d ' ' -f 4 /etc/centos-release | cut -d '.' -f 1)
#   定义当前系统架构
centos_arch=$(arch)

#   检查服务是否安装
notInstalled() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo -e "\033[31m未安装$1\033[0m"
        return 0
    else
        echo -e "\033[32m已安装$1\033[0m"
    fi
    return 1
}

#   检查文件是否存在
checkExists() {
    if [ -f "$1" ]; then
        echo -e "\033[31m文件不存在:$1\033[0m"
        return 0
    else
        return 1
    fi
}

#   nvm检查和安装
if notInstalled nvm; then
    echo -e '\033[32m正在安装nvm\033[0m'
    #   获取NVM并安装
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh" | bash
fi

#   node检查和安装
if notInstalled node; then
    echo -e '\033[31m正在安装Node\033[0m'
    nvm install $current_node_version
    nvm use $current_node_version
    #   当前Linux只能使用16
    # curl -fsSL "https://rpm.nodesource.com/setup_$current_node_version.x" | sudo bash -
    # sudo yum install nodejs -y
    # sudo npm install npm@latest -g
    npm i -g typescript
    npm config set registry https://registry.npmjs.org
    npm config set ELECTRON_MIRROR http://npm.taobao.org/mirrors/electron/
fi

#   svn检查和安装
if notInstalled svn; then
    echo -e '\033[31m正在安装SVN\033[0m'
    sudo yum install -y subversion
fi

#   git检查和安装
if notInstalled git; then
    sudo yum install -y git

    #   添加git配置
    git config --global http.sslVerify false
    git config --global http.sslVersion tlsv1.2
    git config --global http.postBuffer 524288000
    git config --global core.sparsecheckout true
    git config --global core.autocrlf false
fi

#   mysql检查和安装
if notInstalled mysql; then
    echo -e '\033[31m正在安装Mysql\033[0m'
fi

#   minio检查和安装
if ! checkExists "$current_dir/minio"; then
    echo -e '\033[32m正在安装Minio\033[0m'
    wget https://dl.min.io/server/minio/release/darwin-amd64/minio
    chmod +x minio
fi

#   Gvm检查和安装
if notInstalled gvm; then
    echo -e '\033[32m正在安装Gvm\033[0m'
    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
fi

#   Pyenv检查和安装
if notInstalled pyenv; then
    echo -e '\033[32m正在安装Pyenv\033[0m'
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

    #   添加环境变量和命令处理
    {
        echo "export PYENV_ROOT=\"$HOME/.pyenv\""
        echo "command -v pyenv >/dev/null || export PATH=\"$PYENV_ROOT/bin:$PATH\""
        echo "eval \"$(pyenv init -)\""
    } >>~/.bash_profile
fi
# #   宝塔检查和安装
# if notInstalled baota; then
#     wget -O install.sh http://download.bt.cn/install/install_6.0.sh && sh install.sh
# fi

#   检查安装Nginx
if notInstalled nginx; then
    echo -e '\033[32m正在安装Nginx\033[0m'
    sudo yum install -y nginx
fi

#   检查安装Nginx Unit
if notInstalled unit; then
    echo "[unit]
name=unit repo
baseurl=http://nginx.org/packages/mainline/centos/$centos_release/$centos_arch/
gpgcheck=0
enabled=1" >/etc/yum.repos.d/unit.repo
    sudo yum install -y unit
fi
