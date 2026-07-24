FROM docker.io/ollama/ollama:0.32.3 as ollama

FROM docker.io/node:26-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    git=1:2.47.3-0+deb13u1 \
    ca-certificates=20250419 \
    bubblewrap=0.11.0-2+deb13u1 \
    && rm -rf /var/lib/apt/lists/*
ENV OLLAMA_HOST=127.0.0.1:11434
ENV OLLAMA_MODELS=/var/lib/ollama
WORKDIR /workspace
COPY --from=ollama /usr/bin/ollama /usr/bin/ollama
COPY --from=ollama /usr/lib/ollama /usr/lib/
RUN npm install -g @openai/codex@0.145.0
CMD ["sh", "-c", "ollama serve & until ollama list >/dev/null 2>&1; do sleep 0.5; done; ollama launch codex --model \"$MODEL\""]

LABEL \
org.opencontainers.image.title="codex-ollama" \
org.opencontainers.image.description="Facilitate the use of Ollama models as the backend for OpenAI's Codex CLI tool." \
org.opencontainers.image.source="https://github.com/that1guycolin/container-codex-ollama" \
org.opencontainers.image.licenses="MIT"
