# My-os

## Requirements

- nasm
- make
- qemu-system-i386
- i686-elf-gcc
- i686-elf-binutils

## Build

```bash
## Build the cross-compiler

chmod +x scripts/build-cross.sh
./scripts/build-cross.sh
export PATH="$HOME/opt/cross/bin:$PATH"

## 
make run