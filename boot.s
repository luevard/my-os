[BITS 16] ; Assemble the code for 16-bit real mode
[ORG 0x7C00] ; Conventionnal Bootloader address

start:
    mov bx, msg ; Load the offset address of msg into BX
    call printmsg ; Call printmsg and save return address on the stack
printmsg:
    mov al, [bx] ; Save the current char into al register
    cmp al, 0 ; Compare al register with the '0' value
    jz halt ; If true | set the next code segment to halt function
    mov ah, 0x0E ; BIOS teletype function for displaying one character
    int 0x10 ; Call BIOS video interrupt to print AL
    inc bx ; Increment bx register for point to the next char
    jmp printmsg ; Recursive call

halt: 
    ret ; Return

msg: db 'Hello World!', 0 ; Define "Hello World!\0" string

times 510-($-$$) db 0 ; Fill the boot sector with zeros up to 510 bytes
dw 0xAA55 ; BIOS signature