_add:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
    and r9, rax
    
    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    add rbx, rcx
    mov [registers+r8], rbx
    dispatch
_addc:
    mov r8, (111b<<3)
    and r8, rax

    lodsw
    mov rbx, [registers+r8]
    mov rcx, [rsi + rax - 2]
    add rbx, rcx
    mov [registers+r8], rbx
    dispatch
_sub:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    sub rbx, rcx
    mov [registers+r8], rbx
    dispatch
_subc:
    mov r8, (111b<<3)
    and r8, rax

    lodsw
    mov rbx, [registers+r8]
    mov rcx, [rsi + rax - 2]
    sub rbx, rcx
    mov [registers+r8], rbx
    dispatch
_csub:
    mov r8, (111b<<3)
    and r8, rax

    lodsw
    mov rbx, [rsi + rax - 2]
    mov rcx, [registers+r8]
    sub rbx, rcx
    mov [registers+r8], rbx
    dispatch
_mul:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    imul rbx, rcx
    mov [registers+r8], rbx
    dispatch
_mulc:
    mov r8, (111b<<3)
    and r8, rax

    lodsw
    mov rbx, [registers+r8]
    mov rcx, [rsi + rax - 2]
    imul rbx, rcx
    mov [registers+r8], rbx
    dispatch
_div:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
    and r9, rax

    mov rax, [registers+r8]
    cqo
    mov rbx, [registers+r9*8]
    idiv rbx
    mov [registers+r8], rax
    mov [registers+0], rdx
    xor rax, rax
    dispatch
_divc:
    mov r8, (111b<<3)
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
_and:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    and rbx, rcx
    mov [registers+r8], rbx
    dispatch
_andc:
    mov r8, (111b<<3)
    and r8, rax

    lodsw
    mov rbx, [registers+r8]
    mov rcx, [rsi + rax - 2]
    and rbx, rcx
    mov [registers+r8], rbx
    dispatch
_or:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    or rbx, rcx
    mov [registers+r8], rbx
    dispatch
_orc:
    mov r8, (111b<<3)
    and r8, rax

    lodsw
    mov rbx, [registers+r8]
    mov rcx, [rsi + rax - 2]
    or rbx, rcx
    mov [registers+r8], rbx
    dispatch
_xor:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    xor rbx, rcx
    mov [registers+r8], rbx
    dispatch
_shl:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    shl rbx, cl
    mov [registers+r8], rbx
    dispatch
_shlc:
    mov r8, (111b<<3)
    and r8, rax

    lodsw
    mov cl, al
    mov rbx, [registers+r8]
    shl rbx, cl
    mov [registers+r8], rbx
    dispatch
_cshl:
    mov r8, (111b<<3)
    and r8, rax

    lodsw
    mov rbx, [rsi + rax - 2]
    mov rcx, [registers+r8]
    shl rbx, cl
    mov [registers+r8], rbx
    dispatch
_shr:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    shr rbx, cl
    mov [registers+r8], rbx
    dispatch
_shrc:
    mov r8, (111b<<3)
    and r8, rax

    lodsw
    mov cl, al
    mov rbx, [registers+r8]
    shr rbx, cl
    mov [registers+r8], rbx
    dispatch
_cshr:
    mov r8, (111b<<3)
    and r8, rax

    lodsw
    mov rbx, [rsi + rax - 2]
    mov rcx, [registers+r8]
    shr rbx, cl
    mov [registers+r8], rbx
    dispatch
_sar:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
    and r9, rax

    mov rbx, [registers+r8]
    mov rcx, [registers+r9*8]
    sar rbx, cl
    mov rbx, [registers+r8]
    dispatch
_sarc:
    mov r8, (111b<<3)
    and r8, rax

    lodsw
    mov cl, al
    mov rbx, [registers+r8]
    sar rbx, cl
    mov [registers+r8], rbx
    dispatch
_csar:
    mov r8, (111b<<3)
    and r8, rax
    
    lodsw
    mov rbx, [rsi + rax - 2]
    mov rcx, [registers+r8]
    sar rbx, cl
    mov [registers+r8], rbx
    dispatch
_mov:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
    and r9, rax

    mov rbx, [registers+r9*8]
    mov [registers+r8], rbx
    dispatch
_movp:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
    and r9, rax

    mov rbx, [registers+r9*8]
    mov [registers+r8], rbx
    dispatch
_movc:
    mov r8, (111b<<3)
    and r8, rax

    lodsw
    mov rbx, [rsi + rax - 2]
    mov [registers+r8], rbx
    dispatch
_null:
    mov r8, (111b<<3)
    and r8, rax

    xor rbx, rbx
    mov [registers+r8], rbx
    dispatch
_jmp:
    movsx rbx, word [rsi]
    add rsi, rbx
    dispatch
_jmpf:
    mov ax, [rsi]
    movsx rbx, word [rsi + rax]
    add rsi, rbx
    dispatch
_switch:
    ;;to be written
    dispatch
_jcmp:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
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
_jcmpc:
    mov r8, (111b<<3)
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
_jeqp:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
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
_jnullp:
    mov r8, (111b<<3)
    and r8, rax

    mov r9, 111b
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
_alloc:
    ; to be written
    dispatch
_in:
    xor rax, rax
    call exit
    dispatch
_out:
    ; to be written
    dispatch
_err:
    ; to be written
    dispatch