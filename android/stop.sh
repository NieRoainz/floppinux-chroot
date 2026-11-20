#!/system/bin/sh
set -eu

ROOT=/data/local/chroot-distro/floppinux
[ "$(id -u)" = "0" ] || { echo "Root required (run through su)." >&2; exit 1; }
mounted() { grep -F " $1 " /proc/mounts >/dev/null 2>&1; }
umount_if_mounted() {
  target="$1"
  if mounted "$target"; then umount "$target" || { echo "Could not unmount $target (is a process using it?)" >&2; return 1; }; fi
}

umount_if_mounted "$ROOT/dev/pts"
umount_if_mounted "$ROOT/proc"
umount_if_mounted "$ROOT/sys"
umount_if_mounted "$ROOT/dev"
echo "FLOPPINUX mounts released."
