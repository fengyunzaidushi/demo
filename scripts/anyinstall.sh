#!/bin/bash
clear
echo "==================================="
echo " anytls 一键安装脚本 "
echo "==================================="

PORT=${1:-8443}

if ! [[ "$PORT" =~ ^[0-9]{1,5}$ ]]; then
    echo "端口必须是 1 到 65535 之间的整数。"
    exit 1
fi

PORT=$((10#$PORT))
if (( PORT < 1 || PORT > 65535 )); then
    echo "端口必须是 1 到 65535 之间的整数。"
    exit 1
fi

get_server_ip() {
    local ip

    ip=$(curl -4 -fsS --connect-timeout 3 --max-time 5 https://api.ipify.org 2>/dev/null) || true
    if [ -z "$ip" ]; then
        ip=$(curl -4 -fsS --connect-timeout 3 --max-time 5 https://ifconfig.me/ip 2>/dev/null) || true
    fi
    if [ -z "$ip" ]; then
        ip=$(hostname -I 2>/dev/null | awk '{ for (i = 1; i <= NF; i++) if ($i !~ /:/ && $i !~ /^127\./) { print $i; exit } }')
    fi

    printf '%s' "$ip"
}

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
nohup ./anytls-server -l "0.0.0.0:$PORT" -p "$PASSWORD" > anytls-server.log 2>&1 &

SERVER_IP=$(get_server_ip)

echo "==================================="
echo " 服务已启动，监听端口: $PORT"
echo " 随机生成的密码已保存至 password.txt"
echo " 密码: $PASSWORD"
echo "==================================="

if [ -z "$SERVER_IP" ]; then
    SERVER_IP="请填写服务器IP"
    echo "未能自动检测服务器 IP，请手动替换配置中的 server。"
fi

echo ""
echo "客户端配置："
cat <<EOF
- name: example -01
    type: anytls
    server: "$SERVER_IP"
    port: $PORT
    password: "$PASSWORD"
    client-fingerprint: chrome
    udp: true
    skip-cert-verify: true
EOF
