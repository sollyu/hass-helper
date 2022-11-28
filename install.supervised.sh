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
# 安装环境依赖
#
case $SYSTEM_TYPE in
    "ubuntu" | "debian")
        if ! apt update ; then
            exit 12
        fi
        if ! apt install apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus systemd-journal-remote -y ; then
            exit 13
        fi
        ;;
    "openwrt")
        echo -e "#################################################"
        echo -e "# OpenWrt非常不建议使用supervised版本"
        echo -e "# 因为它会污染OpenWrt的稳定性，并且兼容性也不好"
        echo -e "# 如果您要继续安装 请${COLOR_GREEN}等待20秒${COLOR_END} 否则请立即按下【${COLOR_RED}Crtl+C${COLOR_END}】"
        echo -e "#################################################"
        sleep 20
        if ! opkg update; then
            exit 17
        fi
        if ! opkg install apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus systemd-journal-remote -y; then
            exit 18
        fi
        ;;
    "centos")
        if ! yum check-update ; then
            exit 14
        fi
        if ! yum install apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus systemd-journal-remote -y ; then
            exit 15
        fi
        ;;
    *)
        exit 16
        ;;
esac

#
# os-agent下载&安装
#
GITHUB_OS_AGENT_VERSION=$(curl -s "https://api.github.com/repos/home-assistant/os-agent/releases/latest" | jq --raw-output ".name")
if [ -z "$GITHUB_OS_AGENT_VERSION" ]; then
    GITHUB_OS_AGENT_VERSION=1.4.1
fi
GITHUB_OS_AGENT_DOWNLOAD="https://ghproxy.com/https://github.com/home-assistant/os-agent/releases/download/${GITHUB_OS_AGENT_VERSION}/os-agent_${GITHUB_OS_AGENT_VERSION}_linux_${SYSTEM_PLAT}.deb"
if ! wget "$GITHUB_OS_AGENT_DOWNLOAD"; then
    exit 20
fi
if [ ! -f "./os-agent_${GITHUB_OS_AGENT_VERSION}_linux_${SYSTEM_PLAT}.deb" ]; then
    exit 21
fi
if ! dpkg -i "os-agent_${GITHUB_OS_AGENT_VERSION}_linux_${SYSTEM_PLAT}.deb"; then
    exit 22
fi
if ! rm "os-agent_${GITHUB_OS_AGENT_VERSION}_linux_${SYSTEM_PLAT}.deb"; then
    exit 23
fi

#
# 安装Docker
#
if ! curl -fsSL get.docker.com | DOWNLOAD_URL="https://mirrors.aliyun.com/docker-ce/" sh ; then
    exit 30
fi

#
# 拉取国内镜像
#
function docker_pull_ghcr() {
    if [ -z "$DOCKER_PULL_PROXY" ]; then
        DOCKER_PULL_PROXY=ghcr.dockerproxy.com
        # DOCKER_PULL_PROXY=ghcr.nju.edu.cn
    fi

    if ! docker pull "$DOCKER_PULL_PROXY/$1"; then
        exit 40
    fi

    if [ "$DOCKER_PULL_PROXY" == "ghcr.io" ] ; then
        return
    fi

    if ! docker tag "$DOCKER_PULL_PROXY/$1" "ghcr.io/$1"; then
        exit 41
    fi

    if ! docker rmi "$DOCKER_PULL_PROXY/$1"; then
        exit 42
    fi
}

HASS_STABLE_JSON=$(curl -s "https://version.home-assistant.io/stable.json" | jq)
HASS_STABLE_VERSION_OBSERVER=$(echo "$HASS_STABLE_JSON" | jq --raw-output ".observer")
HASS_STABLE_VERSION_CLI=$(echo "$HASS_STABLE_JSON" | jq --raw-output ".cli")
HASS_STABLE_VERSION_DNS=$(echo "$HASS_STABLE_JSON" | jq --raw-output ".dns")
HASS_STABLE_VERSION_AUDIO=$(echo "$HASS_STABLE_JSON" | jq --raw-output ".audio")
HASS_STABLE_VERSION_MULTICAST=$(echo "$HASS_STABLE_JSON" | jq --raw-output ".multicast")

case $SYSTEM_PLAT in
    "aarch64")
        HASS_STABLE_VERSION_HASS=$(echo "$HASS_STABLE_JSON" | jq --raw-output '.homeassistant."qemuarm-64"')
        docker_pull_ghcr "home-assistant/qemuarm-64-homeassistant:$HASS_STABLE_VERSION_HASS"
        docker_pull_ghcr "home-assistant/aarch64-hassio-supervisor:latest"
        docker_pull_ghcr "home-assistant/aarch64-hassio-observer:$HASS_STABLE_VERSION_OBSERVER"
        docker_pull_ghcr "home-assistant/aarch64-hassio-cli:$HASS_STABLE_VERSION_CLI"
        docker_pull_ghcr "home-assistant/aarch64-hassio-dns:$HASS_STABLE_VERSION_DNS"
        docker_pull_ghcr "home-assistant/aarch64-hassio-audio:$HASS_STABLE_VERSION_AUDIO"
        docker_pull_ghcr "home-assistant/aarch64-hassio-multicast:$HASS_STABLE_VERSION_MULTICAST"
        ;;
    "x86_64")
        HASS_STABLE_VERSION_HASS=$(echo "$HASS_STABLE_JSON" | jq --raw-output '.homeassistant."generic-x86-64"')
        docker_pull_ghcr "home-assistant/generic-x86-64-homeassistant:$HASS_STABLE_VERSION_HASS"
        docker_pull_ghcr "home-assistant/amd64-hassio-supervisor:latest"
        docker_pull_ghcr "home-assistant/amd64-hassio-observer:$HASS_STABLE_VERSION_OBSERVER"
        docker_pull_ghcr "home-assistant/amd64-hassio-cli:$HASS_STABLE_VERSION_CLI"
        docker_pull_ghcr "home-assistant/amd64-hassio-dns:$HASS_STABLE_VERSION_DNS"
        docker_pull_ghcr "home-assistant/amd64-hassio-audio:$HASS_STABLE_VERSION_AUDIO"
        docker_pull_ghcr "home-assistant/amd64-hassio-multicast:$HASS_STABLE_VERSION_MULTICAST"
        ;;
esac

#
# 安装 supervised
#
if [ -f "homeassistant-supervised.deb" ]; then
    rm "homeassistant-supervised.deb"
fi
if ! wget "https://ghproxy.com/https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb"; then
    exit 50
fi
if ! dpkg -i homeassistant-supervised.deb; then
    exit 51
fi

# 
# 修正armbian运行时的错误
# 
