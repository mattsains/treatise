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

FRAME_HEADER_SIZE equ 8

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

        ;Create the first stack frame
        lodsq ;number of locals
        ;advance rsi while we have number of locals
        mov rbx, rax
        add rbx, 63
        shr rbx, 6
        shl rbx, 3 ;(locals.ceil(64)/64)*8
        add rsi, rbx
        
        mov rdi, rax
        add rdi, 11 ;+sham register saving + td ptr
        shl rdi, 3 ;rdi*8
        push rax
        push rsi
        call malloc
        mov rbp, rax
        pop rsi
        pop rax
        add rbp, 0x48 ;skip over sham registers
        mov QWORD [rbp], 0 ;previous rbp field is null
        add rbp, 8
        mov rax, rbp ;use rax for flags+ptr
        or rax, 2 ;obj flag
        mov [rbp], rax
        ;assuming no parameters
        ;fall through to dispatch
        
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