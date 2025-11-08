FROM n8nio/n8n:latest
USER root

# 装 unzip / wget / ca-certificates / ICU（自动适配 apk/apt/microdnf）
RUN set -eux; \
  if command -v apk >/dev/null 2>&1; then \
    apk add --no-cache unzip wget ca-certificates icu-libs; \
  elif command -v apt-get >/dev/null 2>&1; then \
    apt-get update && apt-get install -y --no-install-recommends unzip wget ca-certificates libicu && rm -rf /var/lib/apt/lists/*; \
  elif command -v microdnf >/dev/null 2>&1; then \
    microdnf install -y unzip wget ca-certificates libicu && microdnf clean all; \
  else \
    echo "No supported package manager found"; exit 1; \
  fi

# 根据 CPU 架构 + 是否 Alpine 选择合适的 DCE 资产
ARG TARGETARCH
RUN set -eux; \
  IS_ALPINE=0; command -v apk >/dev/null 2>&1 && IS_ALPINE=1; \
  if [ "$TARGETARCH" = "amd64" ] && [ $IS_ALPINE -eq 1 ]; then \
    DCE_URL="https://github.com/Tyrrrz/DiscordChatExporter/releases/latest/download/DiscordChatExporter.Cli.linux-musl-x64.zip"; \
  elif [ "$TARGETARCH" = "amd64" ]; then \
    DCE_URL="https://github.com/Tyrrrz/DiscordChatExporter/releases/latest/download/DiscordChatExporter.Cli.linux-x64.zip"; \
  elif [ "$TARGETARCH" = "arm64" ]; then \
    DCE_URL="https://github.com/Tyrrrz/DiscordChatExporter/releases/latest/download/DiscordChatExporter.Cli.linux-arm64.zip"; \
  else echo "Unsupported arch: $TARGETARCH"; exit 1; fi; \
  wget -O /tmp/dce.zip "$DCE_URL"; \
  unzip /tmp/dce.zip -d /usr/local/bin/dce; \
  ln -sf /usr/local/bin/dce/DiscordChatExporter.Cli /usr/local/bin/DiscordChatExporter.Cli; \
  chmod +x /usr/local/bin/dce/DiscordChatExporter.Cli /usr/local/bin/DiscordChatExporter.Cli; \
  rm -f /tmp/dce.zip

USER node
WORKDIR /home/node/.n8n
