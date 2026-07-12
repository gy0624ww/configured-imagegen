#!/bin/sh
set -eu

config_path="${CODEX_CONFIG_PATH:-$HOME/.codex/config.toml}"
image_cli="${CODEX_IMAGEGEN_CLI:-$HOME/.codex/skills/.system/imagegen/scripts/image_gen.py}"
python_bin="${CODEX_IMAGEGEN_PYTHON:-$HOME/.codex/skills/configured-imagegen/.venv/bin/python}"
model="${CODEX_IMAGEGEN_MODEL:-gpt-image-2}"

if [ ! -r "$config_path" ]; then
  printf '%s\n' "Error: Codex configuration is not readable: $config_path" >&2
  exit 1
fi

if [ ! -f "$image_cli" ]; then
  printf '%s\n' "Error: bundled image generator is not available: $image_cli" >&2
  exit 1
fi

if [ ! -x "$python_bin" ]; then
  printf '%s\n' "Error: image-generation Python environment is not available: $python_bin" >&2
  exit 1
fi

read_provider_value() {
  awk -v target="$1" '
    /^\[model_providers\.OpenAI\][[:space:]]*$/ { in_provider=1; next }
    /^\[/ { in_provider=0 }
    in_provider {
      line=$0
      sub(/^[[:space:]]*/, "", line)
      if (line ~ "^" target "[[:space:]]*=") {
        sub(/^[^=]*=[[:space:]]*/, "", line)
        sub(/[[:space:]]*#.*/, "", line)
        sub(/[[:space:]]+$/, "", line)
        if (line ~ /^".*"$/) {
          sub(/^"/, "", line)
          sub(/"$/, "", line)
        }
        print line
        exit
      }
    }
  ' "$config_path"
}

base_url=$(read_provider_value base_url)
api_key=$(read_provider_value experimental_bearer_token)

if [ -z "$base_url" ] || [ -z "$api_key" ]; then
  printf '%s\n' "Error: model_providers.OpenAI.base_url and experimental_bearer_token must be configured." >&2
  exit 1
fi

has_model=0
for arg in "$@"; do
  case "$arg" in
    --model|--model=*) has_model=1 ;;
  esac
done

if [ "$has_model" -eq 0 ]; then
  set -- "$@" --model "$model"
fi

OPENAI_BASE_URL="$base_url" OPENAI_API_KEY="$api_key" exec "$python_bin" "$image_cli" "$@"
