movc r0, zero
movc r1, one
loop:
add r0, r1
jmp loop
zero:
dw 0
dw 0
dw 0
dw 0
one:
dw 0
dw 0
dw 0
dw 1