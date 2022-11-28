#!/bin/bash

#####################[常量-开始]######################
VERSION_NAME=1.0.0
STEP_TOTAL="8"
#####################[常量-结束]######################

#####################[颜色-开始]######################
COLOR_RED="\033[31m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"
COLOR_END="\033[0m"
#####################[颜色-结束]######################


#
# 打印脚本头
#
echo -e "[0/$STEP_TOTAL] 感谢使用Docker一键安装脚本"
echo -e "      作者：Sollyu  版本：$VERSION_NAME"
echo -e "      地址：https://github.com/sollyu/hass-helper"
echo -e "如果您错误的运行了本脚本，请在5秒内按下【${COLOR_RED}Ctrl+C${COLOR_END}】来取消安装"
sleep 5


#
# 检查Docker是否安装
#
echo -e "[1/$STEP_TOTAL] 检查Docker是否安装……"
if ! docker -v >/dev/null 2>&1; then
    echo -e "[2/$STEP_TOTAL] 正在安装Docker……"
    echo -e "      这里要下载Docker，可能得需要几分钟"
    if ! curl -fsSL get.docker.com | DOWNLOAD_URL="https://mirrors.aliyun.com/docker-ce/" sh ; then
        exit 1
    fi
fi

echo -e "[3/$STEP_TOTAL] 配置国内源……"
cat <<EOF > /etc/docker/daemon.json
{
    "registry-mirrors": [
        "https://hub-mirror.c.163.com",
        "https://docker.mirrors.ustc.edu.cn",
        "https://registry.docker-cn.com",
        "https://mirror.baidubce.com"
    ],
    "insecure-registries": [
        "registry.docker-cn.com",
        "docker.mirrors.ustc.edu.cn"
    ],
    "debug": false,
    "experimental": true
}
EOF

echo -e "[4/$STEP_TOTAL] 重启Docker……"
. /etc/os-release
case $ID in
    "ubuntu" | "debian" | "centos")
        if ! systemctl restart docker ; then
            echo -e "      重启Docker失败！需要手动重启Docker"
            exit 2
        fi
        ;;
    "openwrt" )
        if ! /etc/init.d/dockerd restart; then
            echo -e "      重启Docker失败！需要手动重启Docker"
            exit 3
        fi
        ;;
    * )
        echo -e "      重启Docker失败！需要手动重启Docker"
        exit 4
        ;;
esac

echo -e "[5/$STEP_TOTAL] !!恭喜完成!!"
