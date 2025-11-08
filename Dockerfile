# 基础镜像：官方 n8n（多架构）
FROM n8nio/n8n:latest

# 用 root 安装工具 & 放置 DCE
USER root

# 安装 unzip 和 wget
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# 根据 CPU 架构下载对应的 DiscordChatExporter CLI（amd64/arm64）
ARG TARGETARCH
RUN set -eux; \
    case "$TARGETARCH" in \
      "amd64") DCE_URL="https://github.com/Tyrrrz/DiscordChatExporter/releases/latest/download/DiscordChatExporter.Cli.linux-x64.zip" ;; \
      "arm64") DCE_URL="https://github.com/Tyrrrz/DiscordChatExporter/releases/latest/download/DiscordChatExporter.Cli.linux-arm64.zip" ;; \
      *) echo "Unsupported arch: $TARGETARCH"; exit 1 ;; \
    esac; \
    echo "Downloading $DCE_URL"; \
    wget -O /tmp/dce.zip "$DCE_URL"; \
    unzip /tmp/dce.zip -d /usr/local/bin/dce; \
    ln -sf /usr/local/bin/dce/DiscordChatExporter.Cli /usr/local/bin/DiscordChatExporter.Cli; \
    chmod +x /usr/local/bin/dce/DiscordChatExporter.Cli /usr/local/bin/DiscordChatExporter.Cli; \
    rm -f /tmp/dce.zip

# 切回 node 用户
USER node

# n8n 的数据目录（记得挂卷到这里）
WORKDIR /home/node/.n8n
