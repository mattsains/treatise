add:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax
    
    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    add rbx, rcx
    mov [registers+r8], rbx
    dispatch
addc:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov rbx, [registers+r8]
    mov rcx, [rsi + rax - 2]
    add rbx, rcx
    mov [registers+r8], rbx
    dispatch
sub:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    sub rbx, rcx
    mov [registers+r8], rbx
    dispatch
subc:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov rbx, [registers+r8]
    mov rcx, [rsi + rax - 2]
    sub rbx, rcx
    mov [registers+r8], rbx
    dispatch
csub:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov rbx, [rsi + rax - 2]
    mov rcx, [registers+r8]
    sub rbx, rcx
    mov [registers+r8], rbx
    dispatch
mul:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    imul rbx, rcx
    mov [registers+r8], rbx
    dispatch
mulc:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov rbx, [registers+r8]
    mov rcx, [rsi + rax - 2]
    imul rbx, rcx
    mov [registers+r8], rbx
    dispatch
div:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rax, [registers+r8]
    cqo
    mov rbx, [registers+r9*8]
    idiv rbx
    mov [registers+r8], rax
    mov [registers+0], rdx
    xor rax, rax
    dispatch
divc:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov rbx, [rsi + rax - 2]
    mov rax, [registers+r8]
    cqo
    idiv rbx
    mov [registers+r8], rax
    mov [registers+0], rdx
    xor rax, rax
    dispatch
and:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    and rbx, rcx
    mov [registers+r8], rbx
    dispatch
andc:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov rbx, [registers+r8]
    mov rcx, [rsi + rax - 2]
    and rbx, rcx
    mov [registers+r8], rbx
    dispatch
or:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    or rbx, rcx
    mov [registers+r8], rbx
    dispatch
orc:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov rbx, [registers+r8]
    mov rcx, [rsi + rax - 2]
    or rbx, rcx
    mov [registers+r8], rbx
    dispatch
xor:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    xor rbx, rcx
    mov [registers+r8], rbx
    dispatch
shl:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    shl rbx, cl
    mov [registers+r8], rbx
    dispatch
shlc:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov cl, al
    mov rbx, [registers+r8]
    shl rbx, cl
    mov [registers+r8], rbx
    dispatch
cshl:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov rbx, [rsi + rax - 2]
    mov rcx, [registers+r8]
    shl rbx, cl
    mov [registers+r8], rbx
    dispatch
shr:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    shr rbx, cl
    mov [registers+r8], rbx
    dispatch
shrc:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov cl, al
    mov rbx, [registers+r8]
    shr rbx, cl
    mov [registers+r8], rbx
    dispatch
cshr:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov rbx, [rsi + rax - 2]
    mov rcx, [registers+r8]
    shr rbx, cl
    mov [registers+r8], rbx
    dispatch
sar:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    sar rbx, cl
    mov rbx, [registers+r8]
    dispatch
sarc:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov cl, al
    mov rbx, [registers+r8]
    sar rbx, cl
    mov [registers+r8], rbx
    dispatch
csar:
    mov r8, (0b111<<3)
    and r8, rax
    
    lodsw
    mov rbx, [rsi + rax - 2]
    mov rcx, [registers+r8]
    sar rbx, cl
    mov [registers+r8], rbx
    dispatch
mov:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rbx, [registers+r9*8]
    mov [registers+r8], rbx
    dispatch
movp:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rbx, [registers+r9*8]
    mov [registers+r8], rbx
    dispatch
movc:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov rbx, [rsi + rax - 2]
    mov [registers+r8], rbx
    dispatch
null:
    mov r8, (0b111<<3)
    and r8, rax

    xor rbx, rbx
    mov [registers+r8], rbx
    dispatch
jmp:
    movsx rbx, word [rsi]
    add rsi, rbx
    dispatch
jmpf:
    mov ax, [rsi]
    movsx rbx, word [rsi + rax]
    add rsi, rbx
    dispatch
switch:
    ;;to be written
    dispatch
jcmp:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    cmp rbx, rcx
    jg .gt
    je .eq
    ; less than:
    movsx rbx, word [rsi]
    jmp .end
    .eq:
    movsx rbx, word [rsi+2]
    jmp .end
    .gt:
    movsx rbx, word [rsi+4]
    .end:
    add rsi, rbx
    dispatch
jcmpc:
    mov r8, (0b111<<3)
    and r8, rax

    lodsw
    mov rbx, [registers+r8]
    mov rcx, [rsi + rax - 2]
    cmp rbx, rcx
    jg .gt
    je .eq
    ;less than:
    movsx rbx, word [rsi]
    jmp .end
    .eq:
    movsx rbx, word [rsi+2]
    jmp .end
    .gt:
    movsx rbx, word [rsi+4]
    .end:
    sub rsi, 2
    add rsi, rbx
    dispatch
jeqp:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    cmp rbx, rcx
    jne .ne
    movsx rbx, word [rsi]
    jmp .end
    .ne:
    movsx rbx, word [rsi+2]
    .end:
    add rsi, rbx
    dispatch
jnullp:
    mov r8, (0b111<<3)
    and r8, rax

    mov r9, 0b111
    and r9, rax

    mov rbx, [registers+r8]
    and rbx, rbx ; TODO: might need to check real NULLness
    jz .z
    ;not-zero(null):
    movsx rbx, word [rsi]
    jmp .end
    .z:
    movsx rbx, word [rsi+2]

    .end:
    add rsi, rbx
    dispatch
alloc:
    ; to be written
    dispatch
in:
    xor rax, rax
    call exit
    dispatch
out:
    ; to be written
    dispatch
err:
    ; to be written
    dispatch