#!/usr/bin/env bash
# Start a COPR build for a GCC snapshot, or build a .deb in a container.

usage()
{
  echo "Usage: $0 <snapshot> <spec|srpm|rpm|deb>"
  echo 'The snapshot argument should be a version and date (e.g. 9-20190310)'
  echo 'or a symbolic name (e.g. LATEST-9).'
}

if [[ $1 == --help ]]
then
  usage
  exit 0
elif [[ $# != 2 ]]
then
  echo "$0: Incorrect number of arguments" >&2
  usage >&2
  exit 1
fi

set -e

echo "### Fetching information for GCC $1 snapshot"

url=https://gcc.gnu.org/pub/gcc/snapshots/$1

fetch_tarfile()
{
  w3m -dump $url/index.html > index.txt
  cat index.txt
  REV=`awk '/master revision/ { getline ; print substr($1, 1, 12) }' index.txt`
  tarfile=`awk '/^gcc-.*tar/ { print $1 }' index.txt`
  if ! test -f $tarfile
  then
    echo '### Downloading source tarball'
    curl -O $url/$tarfile
  fi
  curl --silent -O $url/sha512.sum
  sha512sum --quiet --ignore-missing -c sha512.sum
}

gen_spec()
{
  echo '### Generating RPM spec file'
  m4 -P -DVERSION=$BASE_VER -DPKGREL=3 -DSNAPINFO=${DATE}git${REV} -DSOURCE_URL=https://gcc.gnu.org/pub/gcc/snapshots/${basename#gcc-}/$tarfile -DBASENAME=$basename gcc-latest.spec.m4 > gcc-latest.spec
}

build_srpm()
{
  echo '### Building SRPM'
  local chroot=fedora-rawhide-x86_64
  mock -r $chroot --buildsrpm --spec gcc-latest.spec --sources .
  srpm=$(ls -rt /var/lib/mock/$chroot/result/*.src.rpm | tail -1)
  echo "Built $srpm"
}

build_copr()
{
  echo '### Starting COPR build'
  copr build --nowait gcc-latest $srpm
  echo "Built $srpm"
}

fetch_tarfile $1
echo '### Extracting version from sources'
basename=${tarfile%.tar.*}
BASE_VER=`tar -Oxf $tarfile $basename/gcc/BASE-VER`
DATE=${basename##*-}

gen_deb()
{
  PKGNAME=gcc-latest_$BASE_VER-${DATE}git${REV}
  mkdir context
  ln $tarfile context/$tarfile
  m4 -P -DVERSION=$BASE_VER -DSNAPINFO=${DATE}git${REV} control.m4 > context/control
  m4 -P -DVERSION=$BASE_VER postinst.m4 > context/postinst
  m4 -P -DVERSION=$BASE_VER postrm.m4 > context/postrm
  chmod 0755 context/postinst context/postrm
  m4 -P -DPKGNAME=$PKGNAME -DTARFILE=$tarfile -DBASENAME=$basename Containerfile.m4 > context/Containerfile
  echo '### Initializing container'
  podman build -t image context
  podman create --name cont image
  podman cp cont:/tmp/$PKGNAME.deb .
  podman rm cont
  podman rmi image
  rm -r context
  echo "Built $PKGNAME.deb"
}

case $2 in
  spec | srpm | rpm | all)
    gen_spec
    ;;&
  srpm | rpm | all)
    build_srpm
    ;;&
  rpm | all)
    build_copr
    ;;&
  deb | all)
    gen_deb
    ;;&
  all)
    git checkout gh-pages
    make update
    git checkout master
    ;;
  spec | srpm | rpm | deb)
    ;;
  *)
    echo "$0: Unknown build target: $2" >&2
    exit 1
    ;;
esac
