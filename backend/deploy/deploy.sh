#!/bin/bash

# 设置错误时退出
set -e

# 显示执行的命令
set -x

# 设置工作目录
DEPLOY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$DEPLOY_DIR")"
cd "$PROJECT_DIR"

# 检查Python版本
python3 --version

# 创建并激活虚拟环境
python3 -m venv venv
source venv/bin/activate

# 升级pip
pip install --upgrade pip

# 安装依赖
pip install -r requirements.txt

# 创建必要的目录
mkdir -p logs
mkdir -p cache/audio

# 检查.env文件
if [ ! -f .env ]; then
    echo "错误：缺少.env文件"
    echo "请根据.env.example创建.env文件"
    exit 1
fi

# 启动服务
if [ "$1" = "prod" ]; then
    # 生产环境使用gunicorn
    pip install gunicorn
    gunicorn main:app \
        --bind 0.0.0.0:8000 \
        --workers 4 \
        --worker-class uvicorn.workers.UvicornWorker \
        --daemon \
        --access-logfile logs/access.log \
        --error-logfile logs/error.log
else
    # 开发环境使用uvicorn
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload
fi

echo "部署完成！" 