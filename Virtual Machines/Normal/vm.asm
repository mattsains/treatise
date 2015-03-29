%include "../Common/utility.h.asm"

section .data
prompt: db 'Please enter a string: ', 0
newline: db `\n`, 0
filename: db 'test.txt', 0

section .bss
response: resb 100

section .text
global _start
_start:
        mov rdi, filename
        call file_to_memory

        mov rdi, rax
        call print
        
        xor rdi, rdi
        call exit
