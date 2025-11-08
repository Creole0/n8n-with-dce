# 第1阶段：拿到 DCE CLI 可执行文件
FROM tyrrrz/discordchatexporter:latest AS dce

# 第2阶段：正式的 n8n 基础镜像
FROM n8nio/n8n:latest

# 把 DCE CLI 复制进 n8n 容器
COPY --from=dce /app/DiscordChatExporter.Cli /usr/local/bin/DiscordChatExporter.Cli
RUN chmod +x /usr/local/bin/DiscordChatExporter.Cli

# n8n 的工作目录（Zeabur 会把持久化卷挂在这里）
WORKDIR /home/node/.n8n
