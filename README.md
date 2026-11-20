# FLOPPINUX Chroot

An Android-hosted, standalone minimal Linux userspace inspired by the compactness goals of [FLOPPINUX](https://github.com/w84death/floppinux).

> **Important distinction:** the original FLOPPINUX is an i486 bootable-floppy distribution. An Android chroot shares Android's running kernel and cannot boot that x86 kernel. This project builds independent root filesystems that run directly under Android's kernel; it does not nest inside Parrot and does not replace Android.

## Installation layout

```text
/data/local/chroot-distro/
├── parrot/       # existing distro, untouched
└── floppinux/    # this project's independent root filesystem
```

## Architecture plan

- **ARM64 / AArch64:** native userspace; first supported target.
- **i386:** separate 32-bit x86 userspace, launched with a compatible static QEMU user emulator.
- **x86_64:** separate 64-bit x86 userspace, launched with a compatible static QEMU user emulator.
- All chroots share the Android kernel. Kernel-dependent features must exist in that kernel.
- This project does not claim that the original i486 floppy image can run natively on ARM64.

## Current status

Initial repository scaffold. The installer/build scripts are being developed and tested incrementally. No prebuilt rootfs or bootable floppy image is included yet.

## Planned commands

On a Linux build host (for example, Parrot in your existing chroot):

```sh
./build.sh arm64
./build.sh i386
./build.sh x86_64
./build.sh all
```

On rooted Android, after transferring the generated ARM64 rootfs:

```sh
su
./android/install.sh arm64-rootfs.tar.gz
./android/start.sh
./android/stop.sh
```

The Android installer will target `/data/local/chroot-distro/floppinux` only. It must never write into the Parrot directory.

## Safety

- Installation refuses to overwrite a non-empty target unless explicitly requested.
- Start/stop scripts only manage mounts created for this distro.
- Root access is required for a real Android chroot. Without root, use a PRoot-based approach instead.
- x86 emulation requires QEMU user-mode binaries and target userspace libraries; it is not the same as booting a complete x86 virtual machine.

## License

The original FLOPPINUX project has its own license and source. This adaptation will keep its own scripts/documentation licensing clear and will not copy upstream build assets without checking their license.
