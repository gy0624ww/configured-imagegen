#!/bin/sh
set -eu

skill_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
venv_dir="$skill_dir/.venv"
python_bin="${PYTHON_BIN:-}"

if [ -z "$python_bin" ]; then
  if command -v python3 >/dev/null 2>&1; then
    python_bin=python3
  elif command -v python >/dev/null 2>&1; then
    python_bin=python
  else
    printf '%s\n' "Error: Python 3.9 or later is required." >&2
    exit 1
  fi
fi

if ! "$python_bin" -c 'import sys; raise SystemExit(sys.version_info < (3, 9))'; then
  printf '%s\n' "Error: Python 3.9 or later is required: $python_bin" >&2
  exit 1
fi

if command -v uv >/dev/null 2>&1; then
  uv venv "$venv_dir" --python "$python_bin"
  uv pip install --python "$venv_dir/bin/python" --upgrade 'openai>=1.109.0' 'tomli>=2.0.1; python_version < "3.11"'
else
  "$python_bin" -m venv "$venv_dir"
  "$venv_dir/bin/python" -m pip install --upgrade 'openai>=1.109.0' 'tomli>=2.0.1; python_version < "3.11"'
fi

printf '%s\n' "Configured image-generation environment: $venv_dir"
