#!/bin/bash

#
# 检查hass容器
#
HASS_CONTAINER_NAME=$(docker ps | grep "homeassistant/home-assistant:stable" | awk -F " " '{print $NF}')
if [ -z "$HASS_CONTAINER_NAME" ]; then
    HASS_CONTAINER_NAME=$(docker ps | grep "ghcr.io/home-assistant/qemuarm-64-homeassistant" | awk -F " " '{print $NF}')
fi

if [ -z "$HASS_CONTAINER_NAME" ]; then
    exit 01
fi

#
# 安装hacs
#
if ! docker exec -i "$HASS_CONTAINER_NAME" bash -c "wget -O - https://hacs.vip/get | HUB_DOMAIN=ghproxy.com/github.com bash -"; then
    exit 02
fi

#
# 重启hass
#
if ! docker restart "$HASS_CONTAINER_NAME"; then
    exit 03
fi
