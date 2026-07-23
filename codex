#!/bin/sh

VULKAN=0
MODEL_STORAGE=/var/lib/ollama
VERSION=latest

usage() {
    cat <<EOF
USAGE: ${0##*/} [OPTIONS] MODEL

  Run codex in a podman container using an ollama model (MODEL) as the backend.

OPTIONS:
  -k, --with-vulkan
      Enable vulkan support for Ollama.

  -v, --version VERSION
      Specify a tagged version of the codex-ollama container from the GitHub
      Container Registry.
      DEFAULT: "latest"

  -s, --model-storage DIRECTORY
      Specify location where Ollama models are stored on host.
      DEFAULT: /var/lib/ollama

  -h, --help
      Display this message and exit.
EOF
}

is_dir() {
    verify_dir="$1"
    [ -d "$verify_dir" ] || {
        echo "${verify_dir} does not exist. Exiting..."
        exit 4
    }
}

main() {
    PARSED=$(getopt -o kv:sh -l with-vulkan,version:,model-storage:,help \
        -- "$@") || {
        usage
        exit 1
    }
    eval set -- "$PARSED"
    while true; do
        case "$1" in
            -k | --with-vulkan)
                VULKAN=1
                echo "Vulkan support enabled"
                shift
                ;;
            -v | --version)
                VERSION="$2"
                echo "Using container version ${VERSION}"
                shift 2
                ;;
            -s | --model-storage)
                MODEL_STORAGE="$2"
                is_dir "$MODEL_STORAGE"
                echo "Models will be retrieved from & saved to ${MODEL_STORAGE}"
                shift 2
                ;;
            -h | --help)
                usage
                exit
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Invalid option: $1"
                usage
                exit 2
                ;;
        esac
    done

    if [ $# -gt 1 ]; then
        echo "ERROR: More than one model provided." >&2
        usage
        exit 3
    elif [ $# -eq 0 ]; then
        echo "ERROR: Please provide a model to run." >&2
        usage
        exit 3
    elif [ $# -eq 1 ]; then
        MODEL="$1"
        echo "Running with the model: ${MODEL}."
    fi

    exec podman run -it --rm \
        -e MODEL="$MODEL" \
        -e OLLAMA_VULKAN=$VULKAN \
        -v "${HOME}/.ollama:/root/.ollama" \
        -v "${PWD}:/workspace" \
        -v "${MODEL_STORAGE}:/var/lib/ollama" \
        ghcr.io/that1guycolin/codex-ollama:"${VERSION}"
}

main "$@"
