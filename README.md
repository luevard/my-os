# My-os

## How to start the OS

`sudo apt install qemu-system-x86`

`git clone https://github.com/luevard/my-os.git`

`cd my-os`

`nasm boot.s -f bin -o boot.bin`

`qemu-system-x86_64 -hda boot.bin`
