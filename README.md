# FLOPPINUX Chroot

An Android-hosted, standalone minimal Linux userspace inspired by the compactness goals of [FLOPPINUX](https://github.com/w84death/floppinux).

> **Important distinction:** the original FLOPPINUX is an i486 bootable-floppy distribution. An Android chroot shares Android's running kernel and cannot boot that x86 kernel. This project builds independent root filesystems that run directly under Android's kernel; it does not nest inside Parrot and does not replace Android.

## Installation layout

```text
/data/local/chroot-distro/
├── parrot/       # existing distro, untouched
└── floppinux/    # this project's independent root filesystem
```

## Architecture

- **ARM64 / AArch64:** native userspace; primary Android chroot.
- **i386:** separate 32-bit x86 userspace archive; execution on ARM64 requires QEMU user-mode and target libraries.
- **x86_64:** separate 64-bit x86 userspace archive; execution on ARM64 requires QEMU user-mode and target libraries.
- All chroots share the Android kernel. Kernel-dependent features must exist in that kernel.
- The original i486 floppy kernel is not booted inside this Android chroot.

See [architecture and support boundaries](docs/architecture.md).

## Current status

The repository now contains an initial bootstrap scaffold:
- Multi-architecture Alpine minirootfs downloader/build wrapper.
- Android rootfs installer targeting only `/data/local/chroot-distro/floppinux`.
- Android chroot start/stop scripts.
- Shell syntax CI.

**This is not a finished release yet.** The scripts have not been run on your phone, and x86 QEMU runtime integration and end-to-end testing remain outstanding. No prebuilt rootfs or bootable floppy image is committed.

## Build rootfs archives

On a Linux build host (for example, Parrot in your existing chroot), install `curl`, `tar`, `grep` and `sort`, then run:

```sh
sh build.sh arm64
sh build.sh i386
sh build.sh x86_64
sh build.sh all
```

Archives and manifests are written to `dist/`. The build downloads minimal Alpine userspaces; it does not compile a new Linux kernel.

## Install and start on rooted Android

Transfer `dist/floppinux-arm64-rootfs.tar.gz` to your phone, then run as root:

```sh
su
sh /path/to/repository/android/install.sh /path/to/floppinux-arm64-rootfs.tar.gz
sh /path/to/repository/android/start.sh
```

After leaving the chroot with `exit`, release its mounts:

```sh
sh /path/to/repository/android/stop.sh
```

The installer targets `/data/local/chroot-distro/floppinux` only. It refuses to overwrite a non-empty target unless `FORCE=1` is explicitly set. It never writes into the Parrot directory.

## Safety and kernel boundary

- A real Android chroot requires root. Without root, a PRoot-based approach is needed.
- `uname -m` inside the chroot reports the host kernel architecture (normally `aarch64`), even when x86 userspace files are present.
- x86 emulation requires QEMU user-mode binaries and target userspace libraries; it is not the same as booting a complete x86 virtual machine.

## License

The original FLOPPINUX project has its own license and source. This adaptation keeps its scripts/documentation separate and does not copy upstream build assets without checking their license.
