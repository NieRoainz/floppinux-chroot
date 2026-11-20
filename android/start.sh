#!/system/bin/sh
set -eu

ROOT=/data/local/chroot-distro/floppinux
[ "$(id -u)" = "0" ] || { echo "Root required (run through su)." >&2; exit 1; }
[ -x "$ROOT/bin/sh" ] || { echo "FLOPPINUX rootfs not found at $ROOT" >&2; exit 1; }

mounted() { grep -F " $1 " /proc/mounts >/dev/null 2>&1; }
bind_mount() {
  src="$1"; dst="$2"
  mkdir -p "$dst"
  if ! mounted "$dst"; then mount --bind "$src" "$dst"; fi
}

bind_mount /dev "$ROOT/dev"
mkdir -p "$ROOT/dev/pts" "$ROOT/proc" "$ROOT/sys"
if ! mounted "$ROOT/dev/pts"; then mount -t devpts devpts "$ROOT/dev/pts"; fi
if ! mounted "$ROOT/proc"; then mount -t proc proc "$ROOT/proc"; fi
if ! mounted "$ROOT/sys"; then mount -t sysfs sysfs "$ROOT/sys"; fi

echo "Entering standalone FLOPPINUX chroot. Type 'exit' to leave."
exec chroot "$ROOT" /bin/sh -l
