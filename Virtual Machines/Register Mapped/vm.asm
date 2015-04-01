BITS 64
%include "../Common/utility.h.asm"

%define NL 0x0A

%macro pushq 0
       push rcx
       push rdx
       push r8
       push r9
       push r10
       push rsi
%endmacro

%macro popq 0
       pop rsi
       pop r10
       pop r9
       pop r8
       pop rdx
       pop rcx
%endmacro

section .data
; These are constants
file_error: db 'File not found.', NL, 0
program_loaded: db 'Program loaded', NL, 0

section .bss
; These are variables

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

        dispatch:
        xor rax, rax ;the high portion of rax needs to stay cleared forever
        ;Dispatch now
        %include "templates/dispatch"

        %include "codetable.asm"

        ;End the program
        jmp end

        error_print:
        mov rdi, file_error
        call print

        end:
        xor rdi, rdi
        call exit