FROM debian:stable-slim as ollama
RUN mkdir -p /ollama && apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates=20250419 \
    zstd=1.5.7+dfsg-1 \
    aria2=1.37.0+debian-3
WORKDIR /ollama
RUN aria2c -s 8 -x 8 -k 100M -d '/ollama' -o "ollama-linux-amd64.tar.zst" \
    https://ollama.com/download/ollama-linux-amd64.tar.zst \
    && tar -xf ollama-linux-amd64.tar.zst && rm ollama-linux-amd64.tar.zst

FROM node:26-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    git=1:2.47.3-0+deb13u1 \
    ca-certificates=20250419 \
    bubblewrap=0.11.0-2+deb13u1 \
    && rm -rf /var/lib/apt/lists/*

ENV OLLAMA_HOST=127.0.0.1:11434
ENV OLLAMA_MODELS=/var/lib/ollama
WORKDIR /workspace
COPY --from=ollama /ollama/bin/ollama /usr/bin/ollama
COPY --from=ollama /ollama/lib/ /usr/lib/
RUN npm install -g @openai/codex@0.145.0
CMD ["sh", "-c", "ollama serve & until ollama list >/dev/null 2>&1; do sleep 0.5; done; ollama launch codex --model \"$MODEL\""]
