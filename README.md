## Wine Appimages

This repository uses `github ci` to build `wine` appimages. These do not require
`32-bit glibc`, and therefore, work across several linux distributions out of
the box. The releases included are built from `wine staging`, `wine caffe`,
`wine vaniglia`, and `wine soda`. More information about their characteristics
and differences can be found
[here](https://docs.usebottles.com/components/runners).

## Get Started

Download the latest release for:

| Staging | Caffe | Vaniglia | Soda |
| ------- | --------- | --------- | --------- |
| <img src="./doc/logo-wine.svg" width=100 height=100> | <img src="./doc/logo-caffe.svg" width=100 height=100> | <img src="./doc/logo-vaniglia.svg" width=100 height=100> | <img src="./doc/logo-soda.svg" width=100 height=100>
| [Download](https://github.com/ruanformigoni/wine/releases/download/continuous-staging/wine-staging_7.19-x86_64.AppImage) | [Download](https://github.com/ruanformigoni/wine/releases/download/continuous-caffe/wine-caffe-7.19-continuous-x86_64.AppImage) | [Download](https://github.com/ruanformigoni/wine/releases/download/continuous-vaniglia/wine-vaniglia-7.19-continuous-x86_64.AppImage) | [Download](https://github.com/ruanformigoni/wine/releases/download/continuous-soda/wine-soda-7.0-6-continuous-x86_64.AppImage)

</p>


### Usage Examples

Make the file executable before usage:
```bash
chmod +x wine-*.AppImage
```

---

Run application:
```bash
./wine-*.AppImage my-application.exe
```

---

Wine config:
```bash
./wine-*.AppImage winecfg
```

---

Winetricks:

```bash
./wine-*.AppImage winetricks
```

In case, if FUSE support libraries are not installed on the host system, it is
still possible to run the AppImage

```bash
./wine-*.AppImage --appimage-extract
./squashfs-root/AppRun
```

## Requirements
 * Install required GPU driver pkgs for you GPU both `amd64` & `i386`.
```
MESA
NVIDIA
INTEL
AMD
```
