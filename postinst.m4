#!/bin/sh
test "$1" = "configure" || exit 0
set -x
/opt/gcc-latest/libexec/gcc/x86_64-pc-linux-gnu/VERSION/install-tools/mkheaders
