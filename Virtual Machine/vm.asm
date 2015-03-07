%include "utility.h.asm"

section .data
prompt: db 'Please enter a string: ', 0
newline: db `\n`, 0

section .bss
response: resb 100

section .text
global _start
_start:
        ;print prompt
        mov rdi, prompt 
        call print

        ;get line of input
        mov rdi, response
        mov rsi, 100
        call read_line

        ;print that
        mov rdi, response
        call print

        mov rdi, newline
        call print
        
        xor rdi, rdi
        call exit
