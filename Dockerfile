# 使用官方 n8n（多架构、多发行版）
FROM n8nio/n8n:latest

# 先切到 root 方便装工具
USER root

# 安装 unzip / wget / ca-certificates（自动适配 apk/apt/microdnf）
RUN set -eux; \
  if command -v apk >/dev/null 2>&1; then \
    apk add --no-cache unzip wget ca-certificates; \
  elif command -v apt-get >/dev/null 2>&1; then \
    apt-get update && apt-get install -y --no-install-recommends unzip wget ca-certificates && rm -rf /var/lib/apt/lists/*; \
  elif command -v microdnf >/dev/null 2>&1; then \
    microdnf install -y unzip wget ca-certificates && microdnf clean all; \
  else \
    echo "No supported package manager found"; exit 1; \
  fi

# 根据 CPU 架构下载对应的 DiscordChatExporter CLI（amd64/arm64）
ARG TARGETARCH
RUN set -eux; \
  case "$TARGETARCH" in \
    "amd64") DCE_URL="https://github.com/Tyrrrz/DiscordChatExporter/releases/latest/download/DiscordChatExporter.Cli.linux-x64.zip" ;; \
    "arm64") DCE_URL="https://github.com/Tyrrrz/DiscordChatExporter/releases/latest/download/DiscordChatExporter.Cli.linux-arm64.zip" ;; \
    *) echo "Unsupported arch: $TARGETARCH"; exit 1 ;; \
  esac; \
  wget -O /tmp/dce.zip "$DCE_URL"; \
  unzip /tmp/dce.zip -d /usr/local/bin/dce; \
  ln -sf /usr/local/bin/dce/DiscordChatExporter.Cli /usr/local/bin/DiscordChatExporter.Cli; \
  chmod +x /usr/local/bin/dce/DiscordChatExporter.Cli /usr/local/bin/DiscordChatExporter.Cli; \
  rm -f /tmp/dce.zip

# 切回 node 用户
USER node

# n8n 数据目录（记得挂卷到这里）
WORKDIR /home/node/.n8n

