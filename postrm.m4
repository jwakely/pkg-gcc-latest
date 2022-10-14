#!/bin/sh
test "$1" = "remove" || exit 0
dir=/opt/gcc-latest/lib/gcc/x86_64-pc-linux-gnu/VERSION/include-fixed
set -ex
test -d "$dir" && rm -r "$dir"
cd /opt
rmdir -p gcc-latest/lib/gcc/x86_64-pc-linux-gnu/VERSION
