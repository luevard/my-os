#!/bin/bash
set -e

TARGET=i686-elf
PREFIX="$HOME/opt/cross"
PATH="$PREFIX/bin:$PATH"

BINUTILS_VERSION=2.46
GCC_VERSION=14.3.0

mkdir -p "$HOME/cross/src" "$HOME/cross/build-binutils" "$HOME/cross/build-gcc" "$PREFIX"
cd "$HOME/cross/src"

[ -f "binutils-$BINUTILS_VERSION.tar.xz" ] || wget "https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.xz"
[ -f "gcc-$GCC_VERSION.tar.xz" ] || wget "https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz"

[ -d "binutils-$BINUTILS_VERSION" ] || tar -xf "binutils-$BINUTILS_VERSION.tar.xz"
[ -d "gcc-$GCC_VERSION" ] || tar -xf "gcc-$GCC_VERSION.tar.xz"

cd "$HOME/cross/src/gcc-$GCC_VERSION"
./contrib/download_prerequisites

cd "$HOME/cross/build-binutils"
"$HOME/cross/src/binutils-$BINUTILS_VERSION/configure" \
  --target="$TARGET" \
  --prefix="$PREFIX" \
  --with-sysroot \
  --disable-nls \
  --disable-werror
make -j"$(nproc)"
make install

cd "$HOME/cross/build-gcc"
"$HOME/cross/src/gcc-$GCC_VERSION/configure" \
  --target="$TARGET" \
  --prefix="$PREFIX" \
  --disable-nls \
  --enable-languages=c,c++ \
  --without-headers
make all-gcc -j"$(nproc)"
make all-target-libgcc -j"$(nproc)"
make install-gcc
make install-target-libgcc

echo
echo "Cross-compiler installed in $PREFIX"