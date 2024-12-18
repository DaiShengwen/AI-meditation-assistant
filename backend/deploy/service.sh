#!/bin/bash

# 设置工作目录
DEPLOY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$DEPLOY_DIR")"
cd "$PROJECT_DIR"

# 服务名称
SERVICE_NAME="ai-meditation"

# PID文件路径
PID_FILE="$PROJECT_DIR/gunicorn.pid"

# 虚拟环境路径
VENV_PATH="$PROJECT_DIR/venv"

# 激活虚拟环境
source "$VENV_PATH/bin/activate"

# 检查服务状态
check_status() {
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null; then
            echo "$SERVICE_NAME 正在运行 (PID: $pid)"
            return 0
        else
            echo "$SERVICE_NAME 未运行 (PID文件存在但进程已终止)"
            rm -f "$PID_FILE"
            return 1
        fi
    else
        echo "$SERVICE_NAME 未运行"
        return 1
    fi
}

# 启动服务
start() {
    echo "正在启动 $SERVICE_NAME..."
    if [ -f "$PID_FILE" ]; then
        echo "PID文件已存在，检查服务是否已在运行..."
        check_status
        if [ $? -eq 0 ]; then
            echo "服务已在运行，无需重复启动"
            return 1
        fi
    fi
    
    # 启动服务
    gunicorn main:app \
        --bind 0.0.0.0:9882 \
        --workers 4 \
        --worker-class uvicorn.workers.UvicornWorker \
        --pid "$PID_FILE" \
        --daemon \
        --access-logfile logs/access.log \
        --error-logfile logs/error.log
        
    sleep 2
    check_status
}

# 停止服务
stop() {
    echo "正在停止 $SERVICE_NAME..."
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        kill "$pid"
        rm -f "$PID_FILE"
        echo "服务已停止"
    else
        echo "PID文件不存在，服务可能未运行"
    fi
}

# 重启服务
restart() {
    stop
    sleep 2
    start
}

# 查看日志
logs() {
    if [ "$1" = "error" ]; then
        tail -f logs/error.log
    else
        tail -f logs/access.log
    fi
}

# 命令行参数处理
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        check_status
        ;;
    logs)
        logs "$2"
        ;;
    *)
        echo "用法: $0 {start|stop|restart|status|logs [error]}"
        exit 1
        ;;
esac

exit 0 