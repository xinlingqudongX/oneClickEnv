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

@REM reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Command Processor" /v "autorun" >NUL
@REM if %errorlevel% == 0 (
@REM     echo 已配置系统CMD终端编码格式
@REM ) else (
@REM     echo 配置系统CMD终端编码格式
@REM     reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Command Processor" /v "autorun" /t REG_SZ /d "chcp 65001>NUL"
@REM )

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

:: Python环境变量配置
setx "PYTHONIOENCODING" "UTF-8"

:: 关闭执行窗口并退出
pause
exit
