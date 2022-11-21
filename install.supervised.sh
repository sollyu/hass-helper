#!/bin/bash

#
# 检查系统
#
. /etc/os-release
case $ID in 
    "ubuntu" | "armbian")
        ;;
    * )
        echo "当前还不支持您的系统"
        ;;
esac

SYSTEM_TYPE="$ID"
SYSTEM_PLAT=$(uname -a | awk -F " " '{print $(NF-1)}')
case $SYSTEM_PLAT in
    "aarch64" | "x86_64" )
        ;;
    * )
        echo "暂时还不支持此CPU架构"
        ;;
esac

