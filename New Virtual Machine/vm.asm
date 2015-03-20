BITS 64
%include "utility.h.asm"

%define NL 0x0A

section .data
; These are constants
error: db 'File not found.', NL, 0
program_loaded: db 'Program loaded', NL, 0

section .bss
; These are variables
registers: resw 6

section .text
global vm_start
vm_start:
        ;rdi: argc
        ;rsi: char* file
        
        mov rdi, rsi
        call file_to_memory

        and rax, rax
        jz errorprint

        ;The file is now in RAM at rax
        push rax
        mov rdi, program_loaded
        call print
        pop rsi

        dispatch:
        xor rax, rax ;the high portion of rax needs to stay cleared forever
        ;Dispatch now
        lodsw

        %include "codetable.asm"

        ;End the program
        jmp end

        errorprint:
        mov rdi, error
        call print

        end:
        xor rdi, rdi
        call exit