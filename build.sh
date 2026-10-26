#!/usr/bin/env sh
# Converts a Markdown file to an N-Pulse PDF (macOS / Linux).
# Usage: ./build.sh docs/file.md [subteam] [title]
set -e

if [ -z "$1" ]; then
  echo "Usage: ./build.sh docs/file.md [subteam] [title]" >&2
  exit 1
fi

cd "$(dirname "$0")"
name=$(basename "$1" .md)
mkdir -p output

set -- "${1#./}" "${2:-}" "${3:-$name}"
typst compile --root . \
  --input src="$1" --input subteam="$2" --input title="$3" \
  template/main.typ "output/$name.pdf"

echo "Created output/$name.pdf"
