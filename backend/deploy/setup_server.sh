#!/bin/bash

# 设置错误时退出
set -e

# 显示执行的命令
set -x

# 检查是否以root运行
if [ "$EUID" -ne 0 ]; then 
    echo "请以root用户运行此脚本"
    exit 1
fi

# 设置变量
APP_USER="aimeditation"
APP_GROUP="aimeditation"
APP_ROOT="/var/www/aimeditation"
BACKEND_DIR="$APP_ROOT/backend"
LOG_DIR="/var/log/aimeditation"
DOMAIN="test.aimeditation.com"

# 更新系统
apt-get update
apt-get upgrade -y

# 安装必要的包
apt-get install -y python3-venv python3-pip nginx certbot python3-certbot-nginx \
    supervisor git curl wget software-properties-common

# 创建应用用户
id -u $APP_USER &>/dev/null || useradd -m -s /bin/bash $APP_USER
usermod -aG www-data $APP_USER

# 创建必要的目录
mkdir -p $APP_ROOT $BACKEND_DIR $LOG_DIR
mkdir -p $BACKEND_DIR/cache/audio

# 设置目录权限
chown -R $APP_USER:$APP_GROUP $APP_ROOT $LOG_DIR
chmod -R 755 $APP_ROOT

# 配置Nginx
cat > /etc/nginx/sites-available/$DOMAIN << EOF
server {
    listen 80;
    server_name $DOMAIN;
    
    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_stapling on;
    ssl_stapling_verify on;
    
    add_header Strict-Transport-Security "max-age=31536000" always;
    
    access_log $LOG_DIR/nginx_access.log;
    error_log $LOG_DIR/nginx_error.log;

    location / {
        proxy_pass http://127.0.0.1:9882;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    location /audio/ {
        alias $BACKEND_DIR/cache/audio/;
        expires 7d;
        add_header Cache-Control "public, no-transform";
    }
}
EOF

# 启用站点配置
ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 获取SSL证书
certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@aimeditation.com

# 复制系统服务文件
cp $BACKEND_DIR/deploy/aimeditation.service /etc/systemd/system/

# 重新加载systemd配置
systemctl daemon-reload

# 启动服务
systemctl enable nginx
systemctl enable aimeditation
systemctl start aimeditation
systemctl restart nginx

# 设置防火墙
ufw allow 'Nginx Full'
ufw allow OpenSSH

# 创建定时任务清理缓存
cat > /etc/cron.daily/cleanup-aimeditation << EOF
#!/bin/bash
find $BACKEND_DIR/cache/audio -type f -mtime +7 -delete
find $LOG_DIR -type f -name "*.log.*" -mtime +30 -delete
EOF

chmod +x /etc/cron.daily/cleanup-aimeditation

echo "部署完成！"
echo "请确保："
echo "1. 已经将代码复制到 $BACKEND_DIR"
echo "2. 已经创建并配置了 .env 文件"
echo "3. 已经正确设置了域名的DNS记录"
echo "4. 已经配置了防火墙规则"
echo "5. 已经设置了监控和告警" 