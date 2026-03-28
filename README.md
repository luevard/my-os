# My-os

## Requirements

- nasm
- make
- g++
- wget
- curl
- gcc
- xz-utils
- bzip2
- own cross-compiler (i686-elf-gcc/i686-elf-binutils) build with [build-cross.sh](scripts/build-cross.sh) script

## Build

```bash
## Build the cross-compiler

cd my-os/
chmod +x scripts/build-cross.sh
./scripts/build-cross.sh

## 
make run