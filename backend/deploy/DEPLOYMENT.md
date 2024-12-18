# AI Meditation 后端部署指南

## 前置要求

1. 一台运行 Ubuntu 20.04 或更高版本的服务器
2. 已注册的域名（例如：test.aimeditation.com）
3. 域名已正确设置DNS记录指向服务器IP
4. OpenAI API密钥
5. TTS服务器配置

## 部署步骤

### 1. 准备服务器

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装基本工具
sudo apt install -y git curl wget
```

### 2. 克隆代码

```bash
# 创建应用目录
sudo mkdir -p /var/www/aimeditation
sudo chown $USER:$USER /var/www/aimeditation

# 克隆代码
cd /var/www/aimeditation
git clone https://github.com/YourUsername/AI-meditation-assistant.git backend
```

### 3. 配置环境

```bash
# 复制环境配置文件
cd /var/www/aimeditation/backend
cp .env.example .env

# 编辑配置文件
nano .env
```

### 4. 运行部署脚本

```bash
# 添加执行权限
chmod +x deploy/*.sh

# 运行部署脚本
sudo ./deploy/setup_server.sh
```

### 5. 验证部署

1. 检查服务状态：
```bash
sudo systemctl status aimeditation
sudo systemctl status nginx
```

2. 检查日志：
```bash
tail -f /var/log/aimeditation/error.log
tail -f /var/log/aimeditation/access.log
```

3. 测试API：
```bash
curl -k https://test.aimeditation.com/health
```

## 安全检查清单

- [ ] 已配置SSL证书
- [ ] 已设置强密码
- [ ] 已配置防火墙
- [ ] 已禁用root SSH登录
- [ ] 已配置API密钥
- [ ] 已设置请求速率限制
- [ ] 已配置CORS
- [ ] 已设置安全响应头

## 监控检查清单

- [ ] 已设置CPU监控
- [ ] 已设置内存监控
- [ ] 已设置磁盘监控
- [ ] 已设置日志监控
- [ ] 已配置错误告警
- [ ] 已设置性能监控
- [ ] 已配置备份策略

## 维护命令

### 服务管理
```bash
# 启动服务
sudo systemctl start aimeditation

# 停止服务
sudo systemctl stop aimeditation

# 重启服务
sudo systemctl restart aimeditation

# 查看状态
sudo systemctl status aimeditation
```

### 日志管理
```bash
# 查看应用日志
sudo tail -f /var/log/aimeditation/error.log

# 查看访问日志
sudo tail -f /var/log/aimeditation/access.log

# 查看Nginx错误日志
sudo tail -f /var/log/nginx/error.log
```

### SSL证书
```bash
# 续期SSL证书
sudo certbot renew
```

### 缓存管理
```bash
# 手动清理过期缓存
sudo -u aimeditation /etc/cron.daily/cleanup-aimeditation
```

## 故障排除

1. 如果服务无法启动：
   - 检查日志文件
   - 验证配置文件
   - 检查权限设置

2. 如果无法访问API：
   - 检查防火墙设置
   - 验证Nginx配置
   - 检查DNS设置

3. 如果SSL证书问题：
   - 检查证书有效期
   - 验证证书配置
   - 检查域名设置

## 联系方式

如有问题，请联系：
- 技术支持：support@aimeditation.com
- 运维团队：ops@aimeditation.com 