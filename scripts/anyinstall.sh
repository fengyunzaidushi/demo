#!/bin/bash
clear
echo "==================================="
echo " anytls 一键安装脚本 "
echo "==================================="

apt update -y
apt install unzip -y

# 下载最新版本
RELEASE_API="https://api.github.com/repos/anytls/anytls-go/releases/latest"
DOWNLOAD_URL=$(wget -qO- --header="Accept: application/vnd.github+json" "$RELEASE_API" | awk -F '"' '/"browser_download_url":[[:space:]]*"[^"]*_linux_amd64\.zip"/ { print $4; exit }')

if [ -z "$DOWNLOAD_URL" ]; then
    echo "未能获取 anytls 最新 Linux AMD64 版本的下载地址。"
    exit 1
fi

ARCHIVE_NAME=${DOWNLOAD_URL##*/}
echo "下载最新版本: $ARCHIVE_NAME"
wget -N "$DOWNLOAD_URL"

# 解压
unzip -o "$ARCHIVE_NAME"

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
