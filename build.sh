#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/dist}"
ALPINE_BASE="${ALPINE_BASE:-https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases}"

usage() {
  echo "Usage: $0 {arm64|i386|x86_64|all}"
}

require() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }

build_one() {
  local target="$1" alpine_arch
  case "$target" in
    arm64) alpine_arch=aarch64 ;;
    i386) alpine_arch=x86 ;;
    x86_64) alpine_arch=x86_64 ;;
    *) echo "Unsupported target: $target" >&2; return 2 ;;
  esac

  local work="$OUT_DIR/work-$target"
  local release_dir="$ALPINE_BASE/$alpine_arch"
  mkdir -p "$work" "$OUT_DIR"
  echo "==> Resolving latest Alpine minirootfs for $target ($alpine_arch)"
  local listing archive
  listing="$(curl -fsSL "$release_dir/")"
  archive="$(printf '%s\n' "$listing" | grep -oE "alpine-minirootfs-[0-9]+\.[0-9]+\.[0-9]+-$alpine_arch\.tar\.gz" | sort -Vu | tail -n1)"
  if [[ -z "$archive" ]]; then
    echo "Could not find a minirootfs archive for $alpine_arch at $release_dir" >&2
    return 1
  fi

  echo "==> Downloading $archive"
  curl -fL "$release_dir/$archive" -o "$work/rootfs.tar.gz"
  tar -tzf "$work/rootfs.tar.gz" >/dev/null
  cp "$work/rootfs.tar.gz" "$OUT_DIR/floppinux-$target-rootfs.tar.gz"
  printf 'target=%s\nalpine_arch=%s\narchive=%s\nsource=%s\n' \
    "$target" "$alpine_arch" "$archive" "$release_dir/$archive" > "$OUT_DIR/floppinux-$target.manifest"
  echo "==> Created $OUT_DIR/floppinux-$target-rootfs.tar.gz"
}

require curl
require tar
require grep
require sort

case "${1:-}" in
  arm64|i386|x86_64) build_one "$1" ;;
  all)
    build_one arm64
    build_one i386
    build_one x86_64
    ;;
  *) usage; exit 2 ;;
esac
