movc r1, 1
movc r5, 0

loop:
    mov r2, r1
    divc r1, 3
    mov r1, r2
    jcmpc r0, 0, acc, acc, cont
    cont:
    divc r1, 5
    mov r1, r2
    jcmpc r0, 0, acc, acc, reject
    acc:
    add r5, r1
    reject:
    addc r1, 1

    jcmpc r1, below, loop, end, end

end:
    in r1

align 8
below:
dq 1000