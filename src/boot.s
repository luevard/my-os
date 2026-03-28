[BITS 16] ; Assemble the code for 16-bit real mode
[ORG 0x7C00] ; Conventional Bootloader load address
KERNEL_START_ADDR equ 0x10000
KERNEL_LOAD_SEG equ 0x1000
CODE_OFFSET equ 0x8
DATA_OFFSET equ 0x10


start:
    cli ; Disable interrupts

    ; Charger le noyau à l'adresse physique 0x10000
    xor ax, ax
    mov ds, ax
    mov ax, KERNEL_LOAD_SEG
    mov es, ax    ; ES = 0x1000
    xor bx, bx                 ; BX = 0x0000
    mov dh, 0
    mov dl, 0x80
    mov cl, 0x02
    mov ch, 0
    mov ah, 0x02
    mov al, 8
    int 0x13

    lgdt [gdt_descriptor] ; Load the GDT descriptor
    mov eax, cr0 ; Save cr0 state (32 bits) into eax register
    or eax, 0x00000001 ; Change the PE bit (bit^0) to 1 to enable protected mode 
    mov cr0, eax ; Save the modification into the cr0 register
    jmp CODE_SEGMENT:start_protected_mode ; jump to 32 bits instructions

gdt_start: ; Describe GDT flat model
    null_descriptor: ; Null descriptor (mandatory first GDT entry)
        dd 0
        dd 0
    code_descriptor: ; Describe flags of code segment
        dw 0xffff ; Memory limit
        dw 0 ; Base low
        db 0 ; Base mid
        db 10011010b ; Access byte: P=1, DPL=00, S=1, Type=1010 (exec/read)
        db 11001111b ; Flags: G=1, D=1, L=0, AVL=0 + Limit high=0xF
        db 0 ; Base high
    data_descriptor: ; Describe flags of data segment
        dw 0xffff
        dw 0
        db 0
        db 10010010b ; Access byte: P=1, DPL=00, S=1, Type=0010 (writable)
        db 11001111b ; Flags: G=1, D=1, L=0, AVL=0 + Limit high=0xF
        db 0
gdt_end: ; End of the GDT

gdt_descriptor: ; Describe size of GDT
    dw gdt_end - gdt_start -1 ; guessing size of GDT
    dd gdt_start ; Base address of the GDT
CODE_SEGMENT equ code_descriptor - gdt_start ; Offset of the code segment descriptor in the GDT
DATA_SEGMENT equ data_descriptor - gdt_start ; Offset of the data segment descriptor in the GDT
halt: 
    jmp $ ; Infinite loop

[BITS 32] ; Assemble the code for 32-bit protected mode
start_protected_mode: ; First 32 bits instructions executed
    mov ax, DATA_OFFSET
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov ss, ax
    mov gs, ax
    mov ebp, 0x9C00
    mov esp, ebp
    in al, 0x92
    or al, 2
    out 0x92, al
    jmp CODE_OFFSET:KERNEL_START_ADDR

times 510-($-$$) db 0 ; Fill the boot sector with zeros up to 510 bytes
dw 0xAA55 ; BIOS signature
