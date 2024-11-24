#!/usr/bin/env bash

# 检测操作系统类型
detect_os() {
    case "$(uname -s)" in
        Linux*)     OS="Linux";;
        MINGW*)     OS="Windows";;
        MSYS*)      OS="Windows";;
        CYGWIN*)    OS="Windows";;
        *)          OS="Unknown";;
    esac
}

# 检查 winget 是否已安装
check_winget_installed() {
    if ! command -v winget &> /dev/null; then
        echo "winget 未安装。"
        if [ "$OS" == "Linux" ]; then
            echo "请根据您的 Linux 发行版安装 winget。例如在 Ubuntu 上："
            echo "sudo apt install winget"
            exit 1
        elif [ "$OS" == "Windows" ]; then
            echo "在 Windows 上安装 winget..."
            install_winget_windows
        else
            echo "未知的操作系统，无法安装 winget。"
            exit 1
        fi
    else
        echo "winget 已安装。"
    fi
}

# 在 Windows 上安装 winget
install_winget_windows() {
    INSTALLER_URL="https://github.com/microsoft/winget-cli/releases/download/v1.9.25200/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    INSTALLER_FILE="Microsoft.DesktopAppInstaller.msixbundle"

    echo "下载 winget 安装包..."
    curl -L -o "$INSTALLER_FILE" "$INSTALLER_URL"

    if [ $? -eq 0 ]; then
        echo "安装包下载成功，开始安装..."
        powershell.exe -Command "Add-AppxPackage -Path $INSTALLER_FILE"
        if [ $? -eq 0 ]; then
            echo "winget 安装成功！"
        else
            echo "winget 安装失败，请手动尝试安装。"
            exit 1
        fi
    else
        echo "下载 winget 安装包失败，请检查网络连接。"
        exit 1
    fi
}

# 安装 VS Code
install_vscode_windows() {
    VSCODE_URL="https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"
    VSCODE_INSTALLER="VSCodeSetup.exe"

    echo "下载 VS Code 安装包..."
    curl -L -o "$VSCODE_INSTALLER" "$VSCODE_URL"

    if [ $? -eq 0 ]; then
        echo "安装包下载成功，开始安装 VS Code..."
        powershell.exe -Command "Start-Process -FilePath $VSCODE_INSTALLER -ArgumentList '/silent' -Wait"
        if [ $? -eq 0 ]; then
            echo "VS Code 安装成功！"
        else
            echo "VS Code 安装失败，请手动尝试安装。"
            exit 1
        fi
    else
        echo "下载 VS Code 安装包失败，请检查网络连接。"
        exit 1
    fi
}

# 询问用户是否安装指定程序的函数
install_program() {
    local program_name=$1

    # 检查程序是否已安装
    if command -v "$program_name" &> /dev/null; then
        echo "$program_name 已安装，跳过安装。"
    else
        echo "$program_name 未安装。是否安装？ (y/n)"
        read -r choice
        if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
            echo "使用 winget 安装 $program_name..."
            winget install --id="$program_name" --silent
        else
            echo "跳过安装 $program_name。"
        fi
    fi
}

# 从文本文件读取程序名并安装
install_from_file() {
    local file_name="program.txt"

    if [ ! -f "$file_name" ]; then
        echo "文件 $file_name 不存在，请检查路径。"
        exit 1
    fi

    while IFS= read -r program_name || [ -n "$program_name" ]; do
        if [ -z "$program_name" ]; then
            continue
        fi

        echo "检查是否安装 $program_name..."
        if winget list | grep -i "$program_name" &> /dev/null; then
            echo "$program_name 已安装，跳过。"
        else
            echo "$program_name 未安装。尝试安装..."
            winget install --id="$program_name" --silent
            if [ $? -eq 0 ]; then
                echo "$program_name 安装成功！"
            else
                echo "$program_name 安装失败，请检查程序名是否正确。"
            fi
        fi
    done < "$file_name"
}

vfox_install() {
    local file_name="vfox_program.txt"

    if [ ! -f "$file_name" ]; then
        echo "文件 $file_name 不存在，请检查路径。"
        exit 1
    fi

    while IFS= read -r program_name || [ -n "$program_name" ]; do
        if [ -z "$program_name" ]; then
            continue
        fi

        echo "检查是否安装 $program_name..."
        if vfox list | grep -i "$program_name" &> /dev/null; then
            echo "$program_name 已安装，跳过。"
        else
            echo "$program_name 未安装。尝试安装..."
            vfox install "$program_name"
            if [ $? -eq 0 ]; then
                echo "$program_name 安装成功！"
            else
                echo "$program_name 安装失败，请检查程序名是否正确。"
            fi
        fi
    done < "$file_name"
}

npm_install() {
    local file_name="npm_program.txt"

    if [ ! -f "$file_name" ]; then
        echo "文件 $file_name 不存在，请检查路径。"
        exit 1
    fi

    while IFS= read -r program_name || [ -n "$program_name" ]; do
        if [ -z "$program_name" ]; then
            continue
        fi

        echo "检查是否安装 $program_name..."
        if npm list -g | grep -i "$program_name" &> /dev/null; then
            echo "$program_name 已安装，跳过。"
        else
            echo "$program_name 未安装。尝试安装..."
            npm install -g "$program_name"
            if [ $? -eq 0 ]; then
                echo "$program_name 安装成功！"
            else
                echo "$program_name 安装失败，请检查程序名是否正确。"
            fi
        fi
    done < "$file_name"
}



main() {
    detect_os
    check_winget_installed
}