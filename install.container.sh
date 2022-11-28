#!/bin/bash

#####################[颜色-开始]######################
COLOR_RED="\033[31m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_END="\033[0m"
#####################[颜色-结束]######################

#
# 检查系统
#
if [ ! -f /etc/os-release ]; then
    echo "当前还不支持您的系统"
    exit 01
fi

#
# 系统类型
#
# shellcheck disable=SC1091
. /etc/os-release
case $ID in
    "ubuntu" | "debian" | "centos")
        SYSTEM_TYPE="$ID"
        ;;
    * )
        echo "当前还不支持您的系统"
        exit 10
        ;;
esac

#
# CPU类型
#
SYSTEM_PLAT=$(uname -a | awk -F " " '{print $(NF-1)}')
case $SYSTEM_PLAT in
    "aarch64" | "x86_64" )
        ;;
    * )
        echo "暂时还不支持此CPU架构"
        exit 11
        ;;
esac

# 
# 检查Docker是否安装
# 
if ! docker -v >/dev/null 2>&1; then
    if ! curl -fsSL get.docker.com | DOWNLOAD_URL="https://mirrors.aliyun.com/docker-ce/" sh ; then
        exit 30
    fi
fi

# 
# Docker配置国内源
# 


# 
# 安装HACS
# 
