@echo off
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
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Command Processor" /v "autorun" /t REG_SZ /d "chcp 65001"
)

@REM 判断winget是否安装
winget >NUL
if %errorlevel% == 0 (
    echo 已安装winget
) else (
    echo 安装winget
    bitsadmin /transfer download /download /priority foreground https://objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/861795c6-2f61-44e0-8c7e-66ed2b5583c1?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20220214%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220214T023759Z&X-Amz-Expires=300&X-Amz-Signature=df884e81debb038b97fdb0cb134bab418661cfb11fbdca40df3eb46e96c19e46&X-Amz-SignedHeaders=host&actor_id=26372348&key_id=0&repo_id=197275130&response-content-disposition=attachment%3B%20filename%3DMicrosoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle&response-content-type=application%2Foctet-stream %CD%/winget.msixbundle
    @REM bitsadmin /monitor
)

:: 下载程序
echo 安装程序
@REM set download_name_list="Google Chrome" "Go Programming Language" "Python 3" "Microsoft Visual Studio Code" "Node.js LTS" "Microsoft To Do: Lists, Tasks & Reminders" "便签" "7-Zip" "钉钉" "WeChat" "微信开发者工具" "腾讯QQ" "potato chat" "TortoiseSVN" "Git" "cmake" "utools"
@REM set download_name_list="Google Chrome"
@REM echo %download_name_list%
for /f %%i in (window_program.txt) do (
    @REM echo %%i
    @REM echo 安装%%i
    
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
echo registry=https://registry.npmjs.org/ > %USERPROFILE%/.npmrc
echo ELECTRON_MIRROR=http://npm.taobao.org/mirrors/electron/ >> %USERPROFILE%/.npmrc

::  添加Git配置
echo "[http]" >> %USERPROFILE%/.gitconfig
echo "    sslVerify = false" >> %USERPROFILE%/.gitconfig
echo "    sslVersion = tlsv1.2" >> %USERPROFILE%/.gitconfig

:: 关闭执行窗口并退出
pause
exit