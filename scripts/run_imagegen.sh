#!/bin/sh
set -eu

skill_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
python_bin="${CODEX_IMAGEGEN_PYTHON:-$skill_dir/.venv/bin/python}"
launcher="$skill_dir/scripts/run_imagegen.py"

if [ ! -x "$python_bin" ]; then
  printf '%s\n' "Error: image-generation Python environment is not available: $python_bin" >&2
  printf '%s\n' "Run: sh \"$skill_dir/scripts/setup_imagegen_env.sh\"" >&2
  exit 1
fi

exec "$python_bin" "$launcher" "$@"
