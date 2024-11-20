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
@REM 下载函数
:downloadFile
set "download_url=%1"
set "download_name=%2"
bitsadmin /transfer download /download /priority foreground "%download_url%" %CD%/%download_name%
@REM bitsadmin /monitor

@REM 判断winget是否安装
winget >NUL
if %errorlevel% == 0 (
    echo 已安装winget
    echo 当前winget版本
    winget -v

    @REM set /p answer=是否更新winget? (y/n):
    @REM if /i "%answer%"=="y" (
    @REM     echo 安装winget
    @REM     call :downloadFile https://github.com/microsoft/winget-cli/releases/download/v1.7.11261/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle winget.msixbundle
    @REM     winget.msixbundle
    @REM     del winget.msixbundle
    @REM )
) else (
    echo 安装winget
    call :downloadFile https://github.com/microsoft/winget-cli/releases/download/v1.9.25200/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle winget.msixbundle
    winget.msixbundle
    del winget.msixbundle
)

:: 下载程序
echo 安装程序
@REM set download_name_list="Google Chrome" "Go Programming Language" "Python 3" "Microsoft Visual Studio Code" "Node.js LTS" "Microsoft To Do: Lists, Tasks & Reminders" "便签" "7-Zip" "钉钉" "WeChat" "微信开发者工具" "腾讯QQ" "potato chat" "TortoiseSVN" "Git" "cmake" "utools"
@REM set download_name_list="Google Chrome"
@REM echo %download_name_list%
for /f %%i in (window_developer.txt) do (
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

::  添加npm配置
echo registry=https://registry.npmjs.org/ >> %USERPROFILE%/.npmrc
echo ELECTRON_MIRROR=http://npm.taobao.org/mirrors/electron/ >> %USERPROFILE%/.npmrc

::  设置vfox的python下载加速
setx -m VFOX_PYTHON_MIRROR  "https://repo.huaweicloud.com/python/"

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
go env -w  GOPROXY=https://goproxy.cn,direct

:: Python环境变量配置 用户环境变量
setx "PYTHONIOENCODING" "UTF-8"

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

@REM 判断是否安装vfox
vfox >NUL
if %errorlevel% == 0 (
    echo 已安装vfox
) else (
    echo 安装vfox
    winget install vfox
    PowerShell New-Item -Type File -Path $PROFILE
    PowerShell Invoke-Item $PROFILE # 打开profile

    echo 将下面一行添加到你的 $PROFILE 文件末尾并保存
    echo Invoke-Expression "$(vfox activate pwsh)"
)

rem 函数定义，用于询问用户并根据回答执行命令
:askAndExecute
set /p answer=是否安装%1? (y/n):
if /i "%answer%"=="y" (
    echo 正在执行:vfox add %1
    rem 这里替换为实际的安装命令，比如使用choco、npm、apt-get等
    vfox add %1
    vfox install %1
) else (
    echo 跳过安装%1
)

:initFlutter
    rem 函数

call :initFlutter
call :askAndExecute python
call :askAndExecute nodejs
call :askAndExecute golang

:initFlutter
    rem 函数

call :initFlutter

@REM :: 安装node包
@REM for /f %%i in (npm.txt) do (
@REM     npm install -g %%i
@REM )

@REM :: 安装python包
@REM for /f %%i in (pip.txt) do (
@REM     pip install %%i
@REM )

:: 关闭执行窗口并退出
pause
exit
