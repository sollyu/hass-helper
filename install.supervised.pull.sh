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
# 拉取国内镜像
#
function docker_pull_ghcr() {
    if ! docker pull "ghcr.dockerproxy.com/$1"; then
        exit 40
    fi
    if ! docker tag "ghcr.dockerproxy.com/$1" "ghcr.io/$1"; then
        exit 41
    fi
    if ! docker rmi "ghcr.dockerproxy.com/$1"; then
        exit 42
    fi
}


rm -rf stable.json*
wget "https://version.home-assistant.io/stable.json"
HASS_STABLE_VERSION_SUPERVISOR=$(jq --raw-output ".supervisor" stable.json)
HASS_STABLE_VERSION_OBSERVER=$(jq --raw-output ".observer" stable.json)
HASS_STABLE_VERSION_CLI=$(jq --raw-output ".cli" stable.json)
HASS_STABLE_VERSION_DNS=$(jq --raw-output ".dns" stable.json)
HASS_STABLE_VERSION_AUDIO=$(jq --raw-output ".audio" stable.json)
HASS_STABLE_VERSION_MULTICAST=$(jq --raw-output ".multicast" stable.json)

case $SYSTEM_PLAT in
    "aarch64")
        HASS_STABLE_VERSION_HASS=$(jq --raw-output '.homeassistant."qemuarm-64"' stable.json)
        docker_pull_ghcr "home-assistant/aarch64-hassio-supervisor:$HASS_STABLE_VERSION_SUPERVISOR"
        docker_pull_ghcr "home-assistant/aarch64-hassio-observer:$HASS_STABLE_VERSION_OBSERVER"
        docker_pull_ghcr "home-assistant/aarch64-hassio-cli:$HASS_STABLE_VERSION_CLI"
        docker_pull_ghcr "home-assistant/aarch64-hassio-dns:$HASS_STABLE_VERSION_DNS"
        docker_pull_ghcr "home-assistant/aarch64-hassio-audio:$HASS_STABLE_VERSION_AUDIO"
        docker_pull_ghcr "home-assistant/aarch64-hassio-multicast:$HASS_STABLE_VERSION_MULTICAST"
        docker_pull_ghcr "home-assistant/qemuarm-64-homeassistant:$HASS_STABLE_VERSION_HASS"
        ;;
    "x86_64")
        HASS_STABLE_VERSION_HASS=$(jq --raw-output '.homeassistant."generic-x86-64"' stable.json)
        docker_pull_ghcr "home-assistant/amd64-hassio-supervisor:$HASS_STABLE_VERSION_SUPERVISOR"
        docker_pull_ghcr "home-assistant/amd64-hassio-observer:$HASS_STABLE_VERSION_OBSERVER"
        docker_pull_ghcr "home-assistant/amd64-hassio-cli:$HASS_STABLE_VERSION_CLI"
        docker_pull_ghcr "home-assistant/amd64-hassio-dns:$HASS_STABLE_VERSION_DNS"
        docker_pull_ghcr "home-assistant/amd64-hassio-audio:$HASS_STABLE_VERSION_AUDIO"
        docker_pull_ghcr "home-assistant/amd64-hassio-multicast:$HASS_STABLE_VERSION_MULTICAST"
        docker_pull_ghcr "home-assistant/generic-x86-64-homeassistant:$HASS_STABLE_VERSION_HASS"
        ;;
esac


#
# 安装 supervised
#
if ! wget "https://ghproxy.com/https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb"; then
    exit 50
fi
if ! dpkg -i homeassistant-supervised.deb; then
    exit 51
fi
