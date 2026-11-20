#!/system/bin/sh
set -eu

BASE=/data/local/chroot-distro
TARGET="$BASE/floppinux"
ARCHIVE="${1:-}"
FORCE="${FORCE:-0}"

if [ "$(id -u)" != "0" ]; then
  echo "Run as root: su -c '$0 /path/to/floppinux-arm64-rootfs.tar.gz'" >&2
  exit 1
fi
if [ -z "$ARCHIVE" ] || [ ! -f "$ARCHIVE" ]; then
  echo "Usage: $0 /path/to/floppinux-arm64-rootfs.tar.gz" >&2
  exit 2
fi
case "$ARCHIVE" in
  *arm64*) ;;
  *) echo "This installer currently accepts the ARM64 rootfs archive only." >&2; exit 2 ;;
esac

mkdir -p "$BASE"
if [ -d "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null || true)" ]; then
  if [ "$FORCE" != "1" ]; then
    echo "Refusing to overwrite non-empty $TARGET." >&2
    echo "Back it up/remove it yourself, or set FORCE=1 after checking the contents." >&2
    exit 1
  fi
  echo "FORCE=1: replacing $TARGET"
  rm -rf "$TARGET"
fi

mkdir -p "$TARGET"
tar -xzf "$ARCHIVE" -C "$TARGET"
mkdir -p "$TARGET"/dev "$TARGET"/proc "$TARGET"/sys "$TARGET"/dev/pts "$TARGET"/root
chmod 0755 "$TARGET"
echo "Installed ARM64 userspace at $TARGET"
echo "Start it with: su -c /data/local/chroot-distro/floppinux/android/start.sh"
