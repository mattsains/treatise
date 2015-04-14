BITS 64
%include "../Common/utility.h.asm"

%define NL 0x0A

;Include vector table
%include "vectors.asm"

%macro dispatch 0
       lodsw
       mov rbx, rax
       shr rbx, 9
       jmp [vectors+rbx*8]
%endmacro

section .data
file_error: db 'File not found.', NL, 0
program_loaded: db 'Program loaded', NL, 0

section .bss
registers: resq 6

section .text
global vm_start
vm_start:
        ;rdi: argc
        ;rsi: char* file
        
        mov rdi, rsi
        call file_to_memory

        and rax, rax
        jz error_print

        ;The file is now in RAM at rax
        push rax
        mov rdi, program_loaded
        call print
        pop rsi

        first_dispatch:
        xor rax, rax ;the high portion of rax needs to stay cleared forever
        ;Dispatch now
        dispatch
        
        %include "code.asm"

        ;End the program
        jmp end

        error_print:
        mov rdi, file_error
        call print

        end:
        xor rdi, rdi
        call exit