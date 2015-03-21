movc r0, 0
movc r1, 1
loop:
mov r3, r0
add r3, r1
mov r0, r1
mov r1, r3
jcmpc r1, 100, loop, end, end
end:
jmp -2
