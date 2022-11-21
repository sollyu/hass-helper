#!/bin/bash

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
    "ubuntu" | "armbian")
        SYSTEM_TYPE="$ID"
        ;;
    * )
        echo "当前还不支持您的系统"
        exit 02
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
        exit 03
        ;;
esac

#
# 安装环境依赖
#
case $SYSTEM_TYPE in
    "ubuntu" | "armbian")
        if ! apt update ; then
            exit 04
        fi
        if ! apt install apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus systemd-journal-remote -y ; then
            exit 05
        fi
        ;;
    *)
        exit 06
        ;;
esac

#
# os-agent下载&安装
#
GITHUB_OS_AGENT_LATEST=$(curl -s "https://api.github.com/repos/home-assistant/os-agent/releases/latest" | jq --raw-output ".name")
if [ -z "$GITHUB_OS_AGENT_LATEST" ]; then
    GITHUB_OS_AGENT_LATEST=1.4.1
fi
GITHUB_OS_AGENT_DOWNLOAD="https://ghproxy.com/https://github.com/home-assistant/os-agent/releases/download/${GITHUB_OS_AGENT_LATEST}/os-agent_${GITHUB_OS_AGENT_LATEST}_linux_${SYSTEM_PLAT}.deb"
if ! wget "$GITHUB_OS_AGENT_DOWNLOAD"; then
    exit 07
fi
if [ ! -f "./os-agent_${GITHUB_OS_AGENT_LATEST}_linux_${SYSTEM_PLAT}.deb" ]; then
    exit 08
fi
if ! dpkg -i "os-agent_${GITHUB_OS_AGENT_LATEST}_linux_${SYSTEM_PLAT}.deb"; then
    exit 09
fi

#
# 安装Docker
#
if ! curl -fsSL get.docker.com | sh ; then
    exit 10
fi

# hass
if ! wget "https://ghproxy.com/https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb"; then
    exit 11
fi
if ! dpkg -i homeassistant-supervised.deb; then
    exit 12
fi
