FROM ubuntu:16.04
RUN apt-get update
RUN apt-get -y install build-essential curl file flex bison libz-dev perl
COPY TARFILE /tmp
RUN tar -xf /tmp/TARFILE -C /tmp
RUN mkdir -p -m 0755 /tmp/PKGNAME/DEBIAN
COPY control postinst postrm /tmp/PKGNAME/DEBIAN
RUN cd /tmp/BASENAME && ./contrib/download_prerequisites --no-isl
RUN mkdir -p /tmp/BASENAME/objdir
RUN cd /tmp/BASENAME/objdir && ../configure --prefix=/opt/gcc-latest --enable-languages=c,c++ --enable-libstdcxx-debug --enable-libstdcxx-backtrace --disable-bootstrap --disable-multilib --disable-libvtv --with-system-zlib --without-isl --enable-multiarch
RUN make -C /tmp/BASENAME/objdir -j NPROCS
RUN make -C /tmp/BASENAME/objdir install DESTDIR=/tmp/PKGNAME
RUN cd /tmp && dpkg-deb --build PKGNAME
RUN apt-get -y install /tmp/PKGNAME.deb
RUN apt-get -y remove gcc-latest
RUN test ! -d /opt/gcc-latest
