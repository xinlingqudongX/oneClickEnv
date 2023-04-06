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
#   定义gcc下载地址
#   定义make下载地址
gcc_ftp=https://ftp.gnu.org/gnu/gcc/
make_ftp=https://ftp.gnu.org/gnu/make/

#   检查服务是否安装
function notInstalled() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo -e "\033[31m未安装$1\033[0m"
        return 0
    else
        echo -e "\033[32m已安装$1\033[0m"
    fi
    return 1
}

#   检查文件是否存在
function checkExists() {
    if [ -f "$1" ]; then
        echo -e "\033[31m文件不存在:$1\033[0m"
        return 0
    else
        return 1
    fi
}

#   升级gcc
function gccUpgrade() {
    #   获取gcc最新版本
    gcc_versions=$(curl $gcc_ftp | grep -ioP "gcc-[0-9]+.[0-9]+.[0-9]+" | sort -V | uniq)
    echo "$gcc_versions"
    latest_gcc_version=$(echo "$gcc_versions" | awk -F " " '{ print $NF}')
    echo "gcc最新版本为:$latest_gcc_version"

    echo "下载"
    wget "http://ftp.gnu.org/gnu/gcc/$latest_gcc_version/$latest_gcc_version.tar.gz"
    tar -zxvf "$latest_gcc_version"

    cd "$latest_gcc_version" || return
    ./contrib/download_prerquisites
    mkdir build
    cd build || return
    ../configure "--prefix=$latest_gcc_version" --enable-bootstrap --enable-languages=c,c++ --enable-threads=posix --enable-checking=release --enable-multilib --with-system-zlib
}

#   升级make
function makeUpgrade() {
    #   获取make最新版本
    make_versions=$(curl $make_ftp | grep -ioP "make-[0-9]+.[0-9]+(.[0-9])?.tar.gz" | sort -V | uniq)
    echo "$make_versions"
    latest_make_version=$(echo "$make_versions" | awk -F " " '{ print $NF}')
    echo "gcc最新版本为:$latest_make_version"

    echo "下载"
    wget "http://ftp.gnu.org/gnu/gcc/$latest_make_version/$latest_make_version.tar.gz"
    tar -zxvf "$latest_make_version"
    cd "$latest_make_version" || return
    ./configure --prefix=/usr
    type make
    make check
    make install
    #   此时位置可能还需要执行提示的一些命令

    make -v
}

#   升级openssl
function opensslUpgrade() {
    openssl_version="3.1.0"
    openssl_download="https://www.openssl.org/source/openssl-$openssl_version.tar.gz"
    wget $openssl_download
    tar -zxvf "openssl-$openssl_version.tar.gz"
    cd "openssl-$openssl_version" || exit
    ./config --prefix=/usr/local/openssl
    make
    make install

    ln -s /usr/local/lib64/libssl.so.3 /usr/lib64/libssl.so.3
    ln -s /usr/local/lib64/libcrypto.so.3 /usr/lib64/libcrypto.so.3
}

#   获取系统信息
function systemInfo() {
    # 获取存储占用
    storage_usage=$(df -h | awk '$NF=="/"{printf "%s", $5}')

    # 获取CPU核数
    cpu_cores=$(grep -c ^processor /proc/cpuinfo)

    # 获取CentOS版本和系统版本
    os_version=$(cat /etc/redhat-release)
    kernel_version=$(uname -r)

    # 获取内存大小
    memory_size=$(free -h | awk '/^Mem:/{print $2}')

    # 打印输出系统信息
    echo "存储占用：$storage_usage"
    echo "CPU核数：$cpu_cores"
    echo "CentOS版本：$os_version"
    echo "系统版本：$kernel_version"
    echo "内存大小：$memory_size"
}

#   输出日志
echoLogs() {
    echo "$1" >linux-init.logs
}

#   安装数据库
function installDatabase() {
    echo "请选择要安装的数据库，使用逗号分隔多个选项，或输入q退出"
    echo "1. Redis"
    echo "2. MongoDB"
    echo "3. MySQL"
    echo "4. PostgreSQL"
    echo "5. MariaDB"
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
