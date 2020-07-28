FROM ubuntu:16.04
RUN apt-get update
RUN apt-get -y install build-essential curl file flex bison libz-dev
COPY TARFILE /tmp
RUN tar -xf /tmp/TARFILE -C /tmp
RUN mkdir -p -m 0755 /tmp/PKGNAME/DEBIAN
COPY control /tmp/PKGNAME/DEBIAN
RUN bash -c "cd /tmp/BASENAME && ./contrib/download_prerequisites --no-isl"
RUN mkdir -p /tmp/BASENAME/objdir
RUN bash -c "cd /tmp/BASENAME/objdir && ../configure --prefix=/opt/gcc-latest --enable-languages=c,c++ --enable-libstdcxx-debug --disable-bootstrap --disable-multilib --disable-libvtv --with-system-zlib --without-isl --enable-multiarch"
RUN make -C /tmp/BASENAME/objdir -j8
RUN make -C /tmp/BASENAME/objdir install DESTDIR=/tmp/PKGNAME
RUN bash -c "cd /tmp && dpkg-deb --build PKGNAME"
