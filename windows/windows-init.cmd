@echo off
chcp 65001
:: 开始执行脚本
SETLOCAL ENABLEEXTENSIONS
SET script_name=%~n0
SET script_path=%~dp0

title "初始化系统"

:: 获取管理员权限
if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%~dp0
bcdedit >nul
if '%errorlevel%' NEQ '0' (goto UACPrompt) else (goto UACAdmin)
:UACPrompt
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
exit /B
:UACAdmin
cd /d "%~dp0"
echo 当前运行路径是：%CD%
echo 已获取管理员权限
@REM pause

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Command Processor" /v "autorun" >NUL
if %errorlevel% == 0 (
    echo 已配置系统CMD终端编码格式
) else (
    echo 配置系统CMD终端编码格式
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Command Processor" /v "autorun" /t REG_SZ /d "chcp 65001>NUL"
)

@REM 判断winget是否安装
winget >NUL
if %errorlevel% == 0 (
    echo 已安装winget
) else (
    echo 安装winget
    bitsadmin /transfer download /download /priority foreground "https://github.com/microsoft/winget-cli/releases/download/v1.4.3132-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" %CD%/winget.msixbundle
    @REM bitsadmin /monitor
    winget.msixbundle
)

:: 下载程序
echo 安装程序
@REM set download_name_list="Google Chrome" "Go Programming Language" "Python 3" "Microsoft Visual Studio Code" "Node.js LTS" "Microsoft To Do: Lists, Tasks & Reminders" "便签" "7-Zip" "钉钉" "WeChat" "微信开发者工具" "腾讯QQ" "potato chat" "TortoiseSVN" "Git" "cmake" "utools"
@REM set download_name_list="Google Chrome"
@REM echo %download_name_list%
for /f %%i in (window_program.txt) do (
    echo %%i
    echo 安装%%i
    
    winget show %%i >nul

    if %errorlevel% == 0 (
        echo 已安装%%i
    ) else (
        echo 开始安装%%i
        winget install %%i
    )
)

:: 安装node包
for /f %%i in (npm.txt) do (
    npm install -g %%i
)

:: 安装python包
for /f %%i in (pip.txt) do (
    pip install %%i
)

::  添加npm配置
echo registry=https://registry.npmjs.org/ >> %USERPROFILE%/.npmrc
echo ELECTRON_MIRROR=http://npm.taobao.org/mirrors/electron/ >> %USERPROFILE%/.npmrc

::  添加Git配置
echo [http]>> %USERPROFILE%/.gitconfig
echo     sslVerify = false>> %USERPROFILE%/.gitconfig
echo     sslVersion = tlsv1.2>> %USERPROFILE%/.gitconfig
echo     postBuffer = 524288000>> %USERPROFILE%/.gitconfig
echo [core]>> %USERPROFILE%/.gitconfig
echo     sparsecheckout = true>> %USERPROFILE%/.gitconfig
echo     autocrlf = false>> %USERPROFILE%/.gitconfig

:: Go环境变量配置
go env -w GO111MODULE=on

:: Python环境变量配置 用户环境变量
setx "PYTHONIOENCODING" "UTF-8"

@REM 判断gvm是否安装
gvm >NUL
if %errorlevel% == 0 (
    echo 已安装gvm
) else (
    echo 安装gvm
    bitsadmin /transfer download /download /priority foreground "https://raw.githubusercontent.com/voidint/g/master/install.ps1" %CD%/gvm_install.ps1
    @REM bitsadmin /monitor

    PowerShell -ExecutionPolicy Bypass -File gvm_install.ps1

    rename %HOME%\.g\bin\g.exe gvm.exe
    ::  设置环境变量
    setx "GOROOT" "%HOME%\.g\go"
    setx "PATH" "%PATH%;%HOME%\.g\bin;%GOROOT%\bin"

    echo 删除安装文件
    del gvm_install.ps1
)


echo 安装Go 1.20
gvm install 1.20

echo 安装Pyenv
@REM 判断pyenv是否安装
pyenv >NUL
if %errorlevel% == 0 (
    echo 已安装Pyenv
) else (
    echo 安装Pyenv
    PowerShell Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
)

@REM 判断nvm是否安装
nvm >NUL
if %errorlevel% == 0 (
    echo 已安装gvm
) else (
    echo 安装nvm
    bitsadmin /transfer download /download /priority foreground "https://github.com/coreybutler/nvm-windows/releases/download/1.1.10/nvm-setup.exe" %CD%/nvm-setup.exe
    @REM bitsadmin /monitor

    echo 开始安装nvm
    nvm-setup.exe

    echo 删除安装文件
    del nvm-setup.exe
)

@REM 判断是否安装DBeaver
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall|find /i "DBeaver">nul 2>nul
if %errorlevel% == 0 (
    echo 已安装DBeaver
) else (
    echo 安装DBeaver
    bitsadmin /transfer download /download /priority foreground "https://dbeaver.io/files/dbeaver-ce-latest-x86_64-setup.exe" %CD%/dbeaver.exe
    @REM bitsadmin /monitor

    echo 开始安装DBeaver
    del dbeaver.exe
)

:initFlutter
    rem 函数

call :initFlutter
:: 关闭执行窗口并退出
pause
exit
