#!/usr/bin/env bash
# ===================================
# DSA 云端部署脚本（Linux / macOS）
# ===================================
# 使用方法:
#   1. 把项目上传到云服务器
#   2. cd daily_stock_analysis-main
#   3. chmod +x deploy.sh && ./deploy.sh
#
# 部署完成后，用浏览器访问: http://你的服务器IP:8000
# ===================================

set -e

echo "========================================"
echo "  DSA 股票分析系统 - 云端部署"
echo "========================================"
echo ""

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "[错误] 未找到 python3，请先安装 Python 3.10+"
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "[信息] Python 版本: $PYTHON_VERSION"

# 创建虚拟环境
if [ ! -d ".venv" ]; then
    echo "[1/5] 创建虚拟环境..."
    python3 -m venv .venv
fi

# 安装依赖
echo "[2/5] 安装 Python 依赖..."
.venv/bin/pip install --upgrade pip -q
.venv/bin/pip install -r requirements.txt -q

# 构建前端（如果 static 目录不存在或为空）
if [ ! -f "static/index.html" ] || [ -z "$(ls -A static/assets 2>/dev/null)" ]; then
    echo "[3/5] 构建前端..."
    if ! command -v node &> /dev/null; then
        echo "[警告] 未找到 Node.js，跳过前端构建。"
        echo "       如需 Web 界面，请安装 Node.js 20+ 后手动运行:"
        echo "         cd apps/dsa-web && npm install && npm run build"
    else
        cd apps/dsa-web
        npm install
        npm run build
        cd ../..
    fi
else
    echo "[3/5] 前端已构建，跳过"
fi

# 确保数据目录存在
mkdir -p data logs reports

echo "[4/5] 检查配置..."
if ! grep -q "WEBUI_HOST=0.0.0.0" .env 2>/dev/null; then
    echo "[警告] .env 中未设置 WEBUI_HOST=0.0.0.0"
    echo "       已自动追加到 .env 文件"
    echo "WEBUI_HOST=0.0.0.0" >> .env
fi

echo "[5/5] 启动服务..."
echo ""
echo "========================================"
echo "  部署完成！"
echo "========================================"
echo ""
echo "  本地访问: http://127.0.0.1:8000"
echo "  公网访问: http://$(curl -s ifconfig.me 2>/dev/null || echo '你的服务器IP'):8000"
echo ""
echo "  首次访问需要设置管理员密码"
echo ""
echo "  后台运行命令:"
echo "    nohup .venv/bin/python webui.py > /dev/null 2>&1 &"
echo ""
echo "  查看日志:"
echo "    tail -f logs/web_server_*.log"
echo ""
echo "========================================"
echo ""

# 启动服务
.venv/bin/python webui.py
