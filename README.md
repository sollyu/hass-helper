# Hass-Helper

这大概是目前`Armbian`中安装`HomeAssistant`最便捷的一个脚本吧。

目前我做了以下主要的事情：

- [x] 常规的盒子一键安装，如：S905系列，N1
- [x] 无需梯子，快速使用国内源下载
- [x] 操作可以断开多次执行

## supervised

⬇️ 第一次执行一键安装
```bash
curl -s https://ghproxy.com/https://raw.githubusercontent.com/sollyu/hass-helper/develop/install.supervised.sh | bash
```

⬇️ 拉取Docker镜像奇慢无比继续执行的脚本

```bash
curl -s https://ghproxy.com/https://raw.githubusercontent.com/sollyu/hass-helper/develop/install.supervised.pull.sh | bash
```

## HACS

⬇️ HACS 自动安装脚本
```bash
curl -s https://ghproxy.com/https://raw.githubusercontent.com/sollyu/hass-helper/develop/install.hacs.sh | bash
```

## Container

⬇️ Docker容器版 目前还没写，打算直接贴Docker命令
```bash
curl -s https://ghproxy.com/https://raw.githubusercontent.com/sollyu/hass-helper/develop/install.container.sh | bash
```

## LICENSE

```

```