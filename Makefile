# Cross-compiler
CC = i686-elf-gcc
AS = nasm
OBJCOPY = i686-elf-objcopy

# Flags
CFLAGS = -std=gnu11 -ffreestanding -O2 -Wall -Wextra
LDFLAGS = -T src/linker.ld -nostdlib

# Files
BOOT = bin/boot.bin
KERNEL_OBJ = obj/kernel.o
KERNEL_ELF = elf/kernel.elf
KERNEL_BIN = bin/kernel.bin
IMAGE = bin/os-image.bin

# Default target
all: $(IMAGE)

# Create output directories
bin obj elf:
	mkdir -p $@

# Bootloader
$(BOOT): src/boot.s | bin
	$(AS) -f bin $< -o $@

# Kernel object
$(KERNEL_OBJ): src/kernel.c | obj
	$(CC) $(CFLAGS) -c $< -o $@

# Kernel ELF
$(KERNEL_ELF): $(KERNEL_OBJ) src/linker.ld | elf
	$(CC) $(CFLAGS) $(LDFLAGS) $(KERNEL_OBJ) -lgcc -o $@

# Kernel binary
$(KERNEL_BIN): $(KERNEL_ELF) | bin
	$(OBJCOPY) -O binary $< $@

# Final disk image
$(IMAGE): $(BOOT) $(KERNEL_BIN) | bin
	cat $(BOOT) $(KERNEL_BIN) > $@

# Run in QEMU
run: $(IMAGE)
	qemu-system- -drive format=raw,file=$(IMAGE)

# Debug mode
debug: $(IMAGE)
	qemu-system-i386 -drive format=raw,file=$(IMAGE) -s -S

# Clean build files
clean:
	rm -rf bin obj elf

.PHONY: all run debug clean