# Binary packages for GCC snapshots

changequote(`[[[',`]]]')dnl
<img src="https://gcc.gnu.org/img/gccegg-65.png" alt="GCC logo" style="float:right; margin-left:10px">

This page links to binary packages for some popular GNU/Linux distributions,
built from recent [snapshots](https://gcc.gnu.org/snapshots.html)
of GCC's development trunk.
These builds are provided for testing purposes,
but are an experiment and might not get updated
and might even get taken down.

Only the C and C++ compilers are included, and only for x86_64,
in a single large package.
I don't intend to split them up into smaller packages,
because the aim is just to provide a testable compiler.

## Reporting bugs

If you find bugs in GCC itself please report them to
[GCC Bugzilla](https://gcc.gnu.org/bugs)
but for problems with how these packages are built
please use the
[GitHub issues tracker](https://github.com/jwakely/pkg-gcc-latest/issues).

## Caveats

### Experimental and potentially unstable

These packages are provided to make it easier for people to try out
the latest GCC code (e.g. in [Travis CI](#travis)) but are not supported,
neither by the GCC project nor by me.
Please test your code with them and provide feedback
(e.g. if you have valid code that no longer compiles,
or runs slower, or faster!)
but don't rely on these packages for your production builds.

For serious purposes you should use supported packages
provided by your linux distribution vendor,
or make your own builds of GCC and support them yourself.


### Dynamic linking

You need to be aware that binaries created by this snapshot compiler
will not know how to find the `libstdc++.so.6` shared library by default.
This can result in errors complaining about `GLIBCXX_3.4.26` not being found.
This is because these packages install libraries to `/opt/gcc-latest/lib64`
and [`ld.so`](https://man7.org/linux/man-pages/man8/ld.so.8.html)
doesn't search in that directory by default.
This can be solved by using `LD_RUN_PATH` or `-Wl,-rpath` (when linking),
or `LD_LIBRARY_PATH` (when running the executables),
or by using `-static` to create static binaries that don't depend on
`libstdc++.so.6` at all.
See [Finding Dynamic or Shared Libraries](https://gcc.gnu.org/onlinedocs/libstdc++/manual/using_dynamic_or_shared.html#manual.intro.using.linkage.dynamic)
in the libstdc++ manual for more details.

### Checking enabled

GCC pre-release snapshots have lots of additional checking enabled
in the compiler, which slows the compiler down considerably.
Please do not report problems with slow compile times using these packages,
unless you're comparing apples to apples
(e.g. comparing to another pre-release build with checking enabled).

## Packages

The latest snapshot is:

      GCC MAJOR-DATE Snapshot

      This snapshot has been generated from the GCC MAJOR git branch
      with the following options:
      git://gcc.gnu.org/git/gcc.git branch master revision GITREV

RPM packages for **Fedora, RHEL, CentOS, and openSUSE**
are built and hosted in the
[jwakely/gcc-latest COPR](https://copr.fedorainfracloud.org/coprs/jwakely/gcc-latest/).

A `.deb` package for **Ubuntu 16.04** is hosted on my personal site
(because large binaries can't be stored in a GitHub repo):

- [DEB](https://kayari.org/gcc-latest/DEB)

The unversioned URL [https://kayari.org/gcc-latest/gcc-latest.deb](https://kayari.org/gcc-latest/gcc-latest.deb)
can be used in scripts and will redirect to the latest `.deb` file.
To download from the unversioned URL but use the real filename use:

      wget --content-disposition https://kayari.org/gcc-latest/gcc-latest.deb

## Source code

The sources for these packages can be found in the Git repository
(at the revision above) or in the corresponding directory at
[https://gcc.gnu.org/pub/gcc/snapshots/](https://gcc.gnu.org/pub/gcc/snapshots/)

The script to create these packages
is on [GitHub](https://github.com/jwakely/pkg-gcc-latest)
(along with any patches applied to the upstream sources).

<a id="travis"></a>
## Travis CI integration

To use these packages with
[Travis CI on GitHub](https://docs.travis-ci.com/user/tutorial/)
you can download and install the `gcc-latest.deb` package
in the `install` phase.

A simple `.travis.yml` file using this package might look like:

        name: CI using gcc-latest

        on:
          push:
            branches: [ $default-branch ]
          pull_request:
            branches: [ $default-branch ]

        jobs:
          build:

            runs-on: ubuntu-latest

            steps:
            - uses: actions/checkout@v3
            - name: install-gcc
              run: |
                  wget --quiet https://kayari.org/gcc-latest/gcc-latest.deb \
                  && sudo dpkg -i gcc-latest.deb
                  echo "/opt/gcc-latest/bin" >> $GITHUB_PATH
                  echo "LD_RUN_PATH=/opt/gcc-latest/lib64" >> $GITHUB_ENV
            - name: configure
              run: ./configure
            - name: make
              run: make
            - name: make check
              run: make check

<a id="container">
## Using a container

To try the build out in a container you can use a `Containerfile`
or `Dockerfile` like [this](containers/fedora/Containerfile):

        FROM fedora:latest
        RUN dnf -y install 'dnf-command(copr)'
        RUN dnf -y copr enable jwakely/gcc-latest
        RUN dnf -y install gcc-latest
        RUN /opt/gcc-latest/bin/g++ --version

Or if you prefer Ubuntu, like [this](containers/ubuntu/Containerfile):

        FROM ubuntu:latest
        RUN apt-get update -y
        RUN apt-get install -y build-essential wget
        RUN wget --quiet https://kayari.org/gcc-latest/gcc-latest.deb
        RUN dpkg -i gcc-latest.deb
        RUN /opt/gcc-latest/bin/g++ --version

