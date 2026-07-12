#!/bin/sh
set -eu

skill_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
venv_dir="$skill_dir/.venv"
python_bin="${PYTHON_BIN:-python3}"

if command -v uv >/dev/null 2>&1; then
  uv venv "$venv_dir" --python "$python_bin"
  uv pip install --python "$venv_dir/bin/python" --upgrade 'openai>=1.109.0'
else
  "$python_bin" -m venv "$venv_dir"
  "$venv_dir/bin/python" -m pip install --upgrade 'openai>=1.109.0'
fi

printf '%s\n' "Configured image-generation environment: $venv_dir"
