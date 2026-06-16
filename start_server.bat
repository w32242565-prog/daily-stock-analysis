@echo off
chcp 65001 >nul
cd /d "%~dp0"

REM 检测是否云端部署（通过 .env 中的 WEBUI_HOST）
findstr /C:"WEBUI_HOST=0.0.0.0" .env >nul 2>&1
if %errorlevel% == 0 (
    echo ============================================
    echo   DSA Web 服务启动器 [云端模式]
    echo ============================================
    echo.
    echo   访问地址:
    echo     本机: http://127.0.0.1:8000
    echo     公网: http://本机IP:8000
    echo.
    echo   首次访问请设置管理员密码
    echo.
) else (
    echo ============================================
    echo   DSA Web 服务启动器 [本地模式]
    echo ============================================
    echo.
    echo   访问地址: http://127.0.0.1:8000
    echo.
)

echo   按 Ctrl+C 停止服务
echo.

.venv\Scripts\python.exe webui.py
pause
