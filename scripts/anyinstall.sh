#!/bin/bash
clear
echo "==================================="
echo " anytls 一键安装脚本 "
echo "==================================="

apt update -y
apt install unzip -y

# 下载
wget -N https://github.com/anytls/anytls-go/releases/download/v0.0.8/anytls_0.0.8_linux_amd64.zip

# 解压
unzip -o anytls_0.0.8_linux_amd64.zip

# 授权
chmod +x anytls-server

echo "==================================="
echo " 安装完成！"
echo " 运行：./anytls-server --help"
echo "==================================="

# 生成随机密码
PASSWORD=$(tr -dc 'A-Za-z0-9#@%' </dev/urandom | head -c 10)
echo "$PASSWORD" > password.txt

# 在后台启动服务
nohup ./anytls-server -l 0.0.0.0:8443 -p "$PASSWORD" > anytls-server.log 2>&1 &

echo "==================================="
echo " 服务已启动，监听端口: 8443"
echo " 随机生成的密码已保存至 password.txt"
echo " 密码: $PASSWORD"
echo "==================================="