# Architecture and support boundaries

## Android relationship

FLOPPINUX is a sibling of Parrot, not a child of it:

```text
Android (existing ARM64 kernel)
└── /data/local/chroot-distro/
    ├── parrot/       # existing environment; never modified by this project
    └── floppinux/    # independent root filesystem
```

A chroot changes the process root and userspace. It does not boot a second kernel. The FLOPPINUX ARM64 userspace therefore uses the Android device's running kernel and its enabled drivers/features.

## Architectures

| Target | Rootfs ABI | How it runs on an ARM64 Android host |
| --- | --- | --- |
| arm64 | AArch64 | Native |
| i386 | 32-bit x86 | QEMU user-mode plus x86 userspace libraries |
| x86_64 | 64-bit x86 | QEMU user-mode plus x86_64 userspace libraries |

The initial bootstrap script downloads Alpine minirootfs archives for these ABIs. This provides a practical small userspace suitable for a chroot; it is not a byte-for-byte port of the original 1.44 MB floppy image.

## x86 emulation status

The current scaffold builds separate i386 and x86_64 rootfs archives. Running them requires QEMU user-mode emulators that can execute on AArch64, plus correct target dynamic loaders/libraries. Emulator installation, launch wrappers and runtime validation remain follow-up implementation work. A full x86 virtual machine is a different mode and requires QEMU system emulation.

## Kernel boundary

All three chroots share Android's kernel. `uname -m` inside the chroot reports the host kernel architecture (normally `aarch64`), even when the userspace contains 32-bit or 64-bit x86 binaries.
