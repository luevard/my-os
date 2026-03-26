[BITS 16] ; Assemble the code for 16-bit real mode
[ORG 0x7C00] ; Conventional Bootloader load address

start:
    cli ; Disable interrupts
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
    mov ecx, 0 ; Set ecx register to 0 (counter)
    mov edi, 0xB8000 ; VGA text memory base address
    mov ebx, msg ; Load the offset address of msg into ebx
    call printmsg ; Set the next code segment to halt function

printmsg:
    mov al, [ebx] ; Save the current char into al register
    mov ah, 0x0f ; Text attribute: black background, bright white foreground
    cmp al, 0 ; Check for end of string (null terminator)
    jz halt ; If true | set the next code segment to halt function
    mov [edi + ecx], ax ; Write the current character and its attribute to VGA text memory with the ax register (al || ah)
    inc ebx ; Increment bx register for point to the next character
    add ecx, 2 ; Move to next character cell in VGA text memory
    jmp printmsg ; Loop to next character

msg: db 'Hello World!', 0 ; Define "Hello World!\0" string

times 510-($-$$) db 0 ; Fill the boot sector with zeros up to 510 bytes
dw 0xAA55 ; BIOS signature
