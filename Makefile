# Cross-compiler
CC = i686-elf-gcc
AS = nasm
OBJCOPY = i686-elf-objcopy

# Flags
CFLAGS = -std=gnu11 -ffreestanding -O2 -Wall -Wextra -ffreestanding -fshort-wchar -g
ASFLAGS = -f elf32 -g -F dwarf
LDFLAGS = -T src/linker.ld -nostdlib

# Directories
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin
ELF_DIR = elf

# Special files
BOOT_SRC = $(SRC_DIR)/boot.s
BOOT_BIN = $(BIN_DIR)/boot.bin
LINKER = $(SRC_DIR)/linker.ld

# Kernel sources only (exclude boot.s)
C_SOURCES = $(wildcard $(SRC_DIR)/*.c)
ASM_SOURCES = $(filter-out $(BOOT_SRC),$(wildcard $(SRC_DIR)/*.s))

# Kernel objects
C_OBJECTS = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(C_SOURCES))
ASM_OBJECTS = $(patsubst $(SRC_DIR)/%.s,$(OBJ_DIR)/%.o,$(ASM_SOURCES))
KERNEL_OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS)

# Outputs
KERNEL_ELF = $(ELF_DIR)/kernel.elf
KERNEL_BIN = $(BIN_DIR)/kernel.bin
IMAGE = $(BIN_DIR)/os-image.bin

# Default target
all: $(IMAGE)

# Create output directories
$(BIN_DIR) $(OBJ_DIR) $(ELF_DIR):
	mkdir -p $@

# Bootloader: raw flat binary
$(BOOT_BIN): $(BOOT_SRC) | $(BIN_DIR)
	$(AS) -f bin $< -o $@

# Compile C kernel files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble kernel ASM files (ELF objects only)
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s | $(OBJ_DIR)
	$(AS) $(ASFLAGS) $< -o $@

# Link kernel ELF
$(KERNEL_ELF): $(KERNEL_OBJECTS) $(LINKER) | $(ELF_DIR)
	$(CC) $(CFLAGS) $(LDFLAGS) $(KERNEL_OBJECTS) -lgcc -o $@

# Convert ELF to flat binary
$(KERNEL_BIN): $(KERNEL_ELF) | $(BIN_DIR)
	$(OBJCOPY) -O binary $< $@

# Final disk image
$(IMAGE): $(BOOT_BIN) $(KERNEL_BIN) | $(BIN_DIR)
	cat $(BOOT_BIN) $(KERNEL_BIN) > $@

# Run in QEMU
run: $(IMAGE)
	qemu-system-i386 -drive format=raw,file=$(IMAGE)

# Debug mode
debug: $(IMAGE)
	qemu-system-i386 -drive format=raw,file=$(IMAGE) -s -S

# Clean build files
clean:
	rm -rf $(BIN_DIR) $(OBJ_DIR) $(ELF_DIR)

.PHONY: all run debug clean