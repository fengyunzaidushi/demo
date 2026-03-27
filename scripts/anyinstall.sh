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