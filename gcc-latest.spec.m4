%global install_prefix /opt/gcc-latest

# Do not check .so files in an application-specific library directory
# or any files in the application's data directory for provides
%global __provides_exclude_from ^%{install_prefix}/%{_lib}/
# Do not generate auto-requires for symlinks to libs in this package.
%global __requires_exclude ^lib(c[cp]1plugin|lto_plugin|atomic|cc1|gomp|itm|quadmath|(hwa|a|l|t|ub)san)\\.so(\\.[[:digit:]]+)*\\(\\)\\(.*\\)$

# Hardening slows the compiler way too much.
%undefine _hardened_build
# Annobin plugin can't be found while configuring libgcc
%undefine _annotated_build
%undefine _missing_build_ids_terminate_build

Name:		gcc-latest
Version:	VERSION
Release:	PKGREL.SNAPINFO%{?dist}
Summary:	Weekly snapshot of GCC trunk

License:	GPLv3+ and GPLv3+ with exceptions and GPLv2+ with exceptions and LGPLv2+ and BSD
URL:		https://gcc.gnu.org/
Source0:	SOURCE_URL

BuildRequires:	gcc, gcc-c++
BuildRequires:	binutils >= 2.24
BuildRequires:	zlib-devel, gettext, dejagnu, bison, flex
BuildRequires:	systemtap-sdt-devel >= 1.3
BuildRequires:	glibc-devel >= 2.17
%if 0%{?fedora} || 0%{?rhel}
BuildRequires:	gmp-devel >= 4.1.2-8, mpfr-devel >= 2.2.1, libmpc-devel >= 0.8.1
BuildRequires:	elfutils-devel >= 0.147
BuildRequires:	elfutils-libelf-devel >= 0.147
BuildRequires:  chrpath
%else
BuildRequires:	gmp-devel >= 4.1.2-8, mpfr-devel >= 2.2.1, mpc-devel >= 0.8.1
BuildRequires:	libdw-devel >= 0.147
BuildRequires:	libelf-devel >= 0.147
%endif
Requires:	binutils >= 2.24
Requires:	glibc >= 2.17

Provides:	bundled(libiberty)


%description
GNU C and C++ compilers built from a weekly development snapshot.

%prep
%setup -q -n BASENAME


%build
CC=gcc
CXX=g++
m4_changequote({{,}})
OPT_FLAGS=`echo %{optflags}|sed -e 's/\(-Wp,\)\?-D_FORTIFY_SOURCE=[12]//g'`
OPT_FLAGS=`echo $OPT_FLAGS|sed -e 's/-flto=auto//g;s/-flto//g;s/-ffat-lto-objects//g'`
OPT_FLAGS=`echo $OPT_FLAGS|sed -e 's/-m64//g;s/-m32//g;s/-m31//g'`
OPT_FLAGS=`echo $OPT_FLAGS|sed -e 's/-mfpmath=sse/-mfpmath=sse -msse2/g'`
OPT_FLAGS=`echo $OPT_FLAGS|sed -e 's/ -pipe / /g'`
OPT_FLAGS=`echo $OPT_FLAGS|sed -e 's/-Werror=format-security/-Wformat-security/g'`
%ifarch %{ix86}
OPT_FLAGS=`echo $OPT_FLAGS|sed -e 's/-march=i.86//g'`
%endif
OPT_FLAGS=`echo "$OPT_FLAGS" | sed -e 's/[[:blank:]]\+/ /g'`
case "$OPT_FLAGS" in
  *-fasynchronous-unwind-tables*)
    sed -i -e 's/-fno-exceptions /-fno-exceptions -fno-asynchronous-unwind-tables /' \
      libgcc/Makefile.in
    ;;
esac
m4_changequote(,)

mkdir objdir
cd objdir
CC="$CC" CXX="$CXX" CFLAGS="$OPT_FLAGS" CXXFLAGS="$OPT_FLAGS" \
  ../configure --prefix=%{install_prefix} --enable-languages=c,c++ \
  --enable-libstdcxx-debug \
  --enable-libstdcxx-backtrace \
  --disable-bootstrap --disable-multilib \
  --disable-libvtv --disable-libssp --disable-libffi \
  --with-system-zlib --without-isl \
  --with-bugurl=https://gcc.gnu.org/bugzilla

make %{?_smp_mflags}


%install
cd objdir
%make_install
for i in $RPM_BUILD_ROOT/%{install_prefix}/lib64/lib*san.so.*
do
  test -f "$i" || continue
  chrpath -l "$i" | grep -q -F %{install_prefix}/lib/../lib64 || continue
  chrpath -c -r '$ORIGIN' "$i"
done


%files
%doc
%{install_prefix}/*


%changelog
* Mon Nov 29 2021 Jonathan Wakely <jwakely@redhat.com> - 12.0.0-2
- Disable annobin

* Fri Nov 26 2021 Jonathan Wakely <jwakely@redhat.com> - 12.0.0-2
- Fix regex for __requires_exclude
- Reenable annobin

* Tue Nov 02 2021 Jonathan Wakely <jwakely@redhat.com> - 12.0.0-1
- Remove '..' components in runpaths

* Mon Nov 02 2020 Jonathan Wakely <jwakely@redhat.com> - 11.0.0-1.1
- Adjust OPT_FLAGS consistently with gcc.spec in Fedora 33

* Tue Jul 28 2020 Jonathan Wakely <jwakely@redhat.com> - 11.0.0-1
- Exclude shared libraries from autodep processing

* Mon Jun 10 2019 Jonathan Wakely <jwakely@redhat.com> - 10.0.0-1
- Removed patch

* Wed Mar 13 2019 Jonathan Wakely <jwakely@redhat.com> - 9.0.1-1
- Created spec file template for COPR builds
