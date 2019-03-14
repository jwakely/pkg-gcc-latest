# Scripts to build binary packages of GCC snapshots

The build.sh script currently supports building RPMs via
[COPR](https://copr.fedorainfracloud.org/)
and a `.deb` for Ubuntu 16.04 (Xenial Xerus).

    Usage: ./build.sh <snapshot> <rpm|deb>
    The snapshot argument should be a version and date (e.g. 9-20190310)
    or a symbolic name (e.g. LATEST-9).

See https://jwakely.github.io/pkg-gcc-latest for prebuilt packages.
