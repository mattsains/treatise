%include "utility.h.asm"

section data
hello: db `Hello world!\n`, 0

section text
global run
run:
        push rbp
        mov rbp, rsp
        
        mov rdi, hello
        call print

        xor rax, rax ; return 0
        mov rsp, rbp
        pop rbp
        ret
