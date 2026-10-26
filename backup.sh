#!/usr/bin/env bash
set -euo pipefail
project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
if [[ ${1:-} == --list ]]; then
  exec python3 "$project_dir/deployment.py" list
fi
exec python3 "$project_dir/deployment.py" backup "$@"
