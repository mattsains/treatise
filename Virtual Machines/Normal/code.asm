_add:
    mov rbx, rax
    and rbx, 111b
    mov rcx, [registers+rbx*8]
    mov rdx, rax
    shr rdx, 3
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    
    add rcx, rdx
    
    mov [registers+rbx*8], rcx
    dispatch
_addc:
    mov rbx, rax
    and rbx, 111b
    mov rcx, [registers+rbx*8]
    
    movsx rax, word [rsi]
    mov rdx, [rsi + rax - 2]
    add rsi, 2
    add rcx, rdx
    
    mov [registers+rbx*8], rcx
    dispatch
_sub:
    mov rbx, rax
    and rbx, 111b
    mov rcx, [registers+rbx*8]
    mov rdx, rax
    shr rdx, 3
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    
    sub rcx, rdx
    
    mov [registers+rbx*8], rcx
    dispatch
_csub:
    mov rbx, rax
    and rbx, 111b
    mov rcx, [registers+rbx*8]
    
    movsx rax, word [rsi]
    mov rdx, [rsi + rax - 2]
    add rsi, 2
    sub rdx, rcx
    
    mov [registers+rbx*8], rdx
    dispatch
_mul:
    mov rbx, rax
    and rbx, 111b
    mov rcx, [registers+rbx*8]
    mov rdx, rax
    shr rdx, 3
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    
    imul rcx, rdx
    
    mov [registers+rbx*8], rcx
    dispatch
_mulc:
    mov rbx, rax
    and rbx, 111b
    mov rcx, [registers+rbx*8]
    
    movsx rax, word [rsi]
    mov rdx, [rsi + rax - 2]
    add rsi, 2
    imul rcx, rdx
    
    mov [registers+rbx*8], rcx
    dispatch
_div:
    mov rbx, rax
    and rbx, 111b
    mov rcx, [registers+rbx*8]
    mov r8, rax
    shr r8, 3
    and r8, 111b
    mov r8, [registers+r8*8]
    
    mov rax, rcx
    cqo
    idiv r8
    mov [registers+rbx*8], rax
    mov [registers+0], rdx
    xor rax, rax
    
    dispatch
_divc:
    mov rbx, rax
    and rbx, 111b

    movsx rax, word [rsi]
    mov rcx, [rsi + rax - 2]
    add rsi, 2
    mov rax, [registers+rbx*8]
    cqo
    idiv rcx
    mov [registers+rbx*8], rax
    mov [registers+0], rdx
    xor rax, rax
    
    dispatch
_cdiv:
    mov rbx, rax
    and rbx, 111b

    movsx rax, word [rsi]
    mov rcx, [registers+rbx*8]
    mov rax, [rsi + rax - 2]
    add rsi, 2
    cqo
    idiv rcx
    mov [registers+rbx*8], rax
    mov [registers+0], rdx
    xor rax, rax
    
    dispatch
_and:
    mov rbx, rax
    and rbx, 111b
    mov rcx, [registers+rbx*8]
    mov rdx, rax
    shr rdx, 3
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    
    and rcx, rdx 
    
    mov [registers+rbx*8], rcx
    dispatch
_andc:
    mov rbx, rax
    and rbx, 111b
    mov rcx, [registers+rbx*8]
    
    movsx rax, word [rsi]
    mov rdx, [rsi + rax - 2]
    add rsi, 2
    and rcx, rdx

    mov [registers+rbx*8], rcx
    dispatch
_or:
    mov rbx, rax
    and rbx, 111b
    mov rcx, [registers+rbx*8]
    mov rdx, rax
    shr rdx, 3
    and rdx, 111b
    mov rdx, [registers+rdx*8]

    or rcx, rdx

    mov [registers+rbx*8], rcx
    dispatch
_orc:
    mov rbx, rax
    and rbx, 111b
    mov rcx, [registers+rbx*8]

    movsx rax, word [rsi]
    mov rdx, [rsi + rax - 2]
    add rsi, 2
    or rcx, rdx

    mov [registers+rbx*8], rcx
    dispatch
_xor:
    mov rbx, rax
    and rbx, 111b
    mov rcx, [registers+rbx*8]
    mov rdx, rax
    shr rdx, 3
    and rdx, 111b
    mov rdx, [registers+rdx*8]

    xor rcx, rdx

    mov [registers+rbx*8], rcx
    dispatch
_shl:
    mov rbx, rax
    and rbx, 111b
    mov rdx, [registers+rbx*8]
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]

    shl rdx, cl

    mov [registers+rbx*8], rcx
    dispatch
_shlc:
    mov rbx, rax
    and rbx, 111b
    mov rdx, [registers+rbx*8]

    lodsw
    mov cl, al
    shl rdx, cl

    mov [registers+rbx*8], rdx
    dispatch
_cshl:
    mov rbx, rax
    and rbx, 111b
    mov rcx, [registers+rbx*8]

    movsx rax, word [rsi]
    mov rdx, [rsi + rax - 2]
    add rsi, 2
    shl rdx, cl

    mov [registers+rbx*8], rdx
    dispatch
_shr:
    mov rbx, rax
    and rbx, 111b
    mov rdx, [registers+rbx*8]
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]

    shr rdx, cl

    mov [registers+rbx*8], rdx
    dispatch
_shrc:
    mov rbx, rax
    and rbx, 111b
    mov rdx, [registers+rbx*8]

    lodsw
    mov cl, al
    shr rdx, cl

    mov [registers+rbx*8], rdx
    dispatch
_cshr:
    mov rbx, rax
    and rbx, 111b
    mov rdx, [registers+rbx*8]

    movsx rax, word [rsi]
    mov rcx, [rsi + rax - 2]
    add rsi, 2
    shr rdx, cl

    mov [registers+rbx*8], rdx
    dispatch
_sar:
    mov rbx, rax
    and rbx, 111b
    mov rdx, [registers+rbx*8]
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]

    sar rdx, cl

    mov [registers+rbx*8], rdx
    dispatch
_sarc:
    mov rbx, rax
    and rbx, 111b
    mov rdx, [registers+rbx*8]

    lodsw
    mov cl, al
    sar rdx, cl

    mov [registers+rbx*8], rdx
    dispatch
_csar:
    mov rbx, rax
    and rbx, 111b
    mov rdx, [registers+rbx*8]

    movsx rax, word [rsi]
    mov rcx, [rsi + rax - 2]
    add rsi, 2
    sar rdx, cl

    mov [registers+rbx*8], rdx
    dispatch
_mov:
    mov rbx, rax
    and rbx, 111b
    mov rdx, rax
    shr rdx, 3
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    mov [registers+rbx*8], rdx
    dispatch
_movp:
    mov rbx, rax
    and rbx, 111b
    mov rdx, rax
    shr rdx, 3
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    mov [registers+rbx*8], rdx    
    dispatch
_movc:
    mov rbx, rax
    and rbx, 111b
  
    movsx rax, word [rsi]
    mov rcx, [rsi + rax - 2]
    add rsi, 2
    mov [registers+rbx*8], rcx
    dispatch
_null:
    mov rbx, rax
    and rbx, 111b
    mov qword [registers+rbx*8], 0
    dispatch
_getl:
    mov rbx, rax
    and rbx, 111b
    lodsw
    mov rcx, [rbp + rax*8 + 8]
    mov [registers+rbx*8], rcx
    dispatch
_getlp:
    mov rbx, rax
    and rbx, 111b
    lodsw
    mov rcx, [rbp + rax*8 + 8]
    mov [registers+rbx*8], rcx
    dispatch
_setl:
    mov rbx, rax
    and rbx, 111b
    mov rbx, [registers+rbx*8]
    lodsw
    mov [rbp + rax*8 + 8], rbx
    dispatch
_setlp:
    mov rbx, rax
    and rbx, 111b
    mov rbx, [registers+rbx*8]
    lodsw
    mov [rbp + rax*8 + 8], rbx
    dispatch
_getm:
    mov rbx, rax
    and rbx, 111b
    mov rdx, rax
    shr rdx, 3
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    lodsw
    mov r8, [rdx + rax*8 + 8]
    mov [registers+rbx*8], r8
    dispatch
_getmp:
    mov rbx, rax
    and rbx, 111b
    mov rdx, rax
    shr rdx, 3
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    lodsw
    mov r8, [rdx + rax*8 + 8]
    mov [registers+rbx*8], r8
    dispatch
_setm:
    mov rbx, rax
    and rbx, 111b
    mov rbx, [registers+rbx*8]
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]
    lodsw
    mov [rbx + rax*8 + 8], rcx
    dispatch
_setmp:
    mov rbx, rax
    and rbx, 111b
    mov rbx, [registers+rbx*8]
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]
    lodsw
    mov [rbx + rax*8 + 8], rcx
    dispatch
_geta:
    mov rbx, rax
    and rbx, 111b
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]
    mov rdx, rax
    shr rdx, 6
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    mov r8, [rcx + rdx*8 + 8]
    mov [registers+rbx*8], r8
    dispatch
_getap:
    mov rbx, rax
    and rbx, 111b
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]
    mov rdx, rax
    shr rdx, 6
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    mov r8, [rcx + rdx*8 + 8]
    mov [registers+rbx*8], r8
    dispatch
_seta:
    mov rbx, rax
    and rbx, 111b
    mov rbx, [registers+rbx*8]
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]
    mov rdx, rax
    shr rdx, 6
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    mov [rbx + rcx*8 + 8], rdx
    dispatch
_setap:
    mov rbx, rax
    and rbx, 111b
    mov rbx, [registers+rbx*8]
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]
    mov rdx, rax
    shr rdx, 6
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    mov [rbx + rcx*8 + 8], rdx
    dispatch
_getb:
    mov rbx, rax
    and rbx, 111b
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]
    mov rdx, rax
    shr rdx, 6
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    movsx r8, byte [rcx + rdx + 8]
    mov [registers+rbx*8], r8
    dispatch
_setb:
    mov rbx, rax
    and rbx, 111b
    mov rbx, [registers+rbx*8]
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]
    mov rdx, rax
    shr rdx, 6
    and rdx, 111b
    mov rdx, [registers+rdx*8]
    mov byte [rbx + rcx + 8], dl
    dispatch
_jmp:
    movsx rbx, word [rsi]
    lea rsi, [rsi + rbx - 2]
    dispatch
_jmpf:
    movsx rax, word [rsi]
    mov rbx, [rsi + rax - 2]
    lea rsi, [rsi + rbx - 2]
    xor rax, rax
    dispatch
_switch:
    and rax, 111b
    mov rbx, [registers+rax*8]
    movsx rax, word [rsi]
    add rsi, 2
    cmp rbx, rax
    jae .default

    mov rax, rbx

    .default:
    lea rsi, [rax * 2 + rsi - 4]
    .dispatch:
    xor rax, rax
    dispatch
_jcmp:
    mov rbx, rax
    and rbx, 111b
    mov rbx, [registers+rbx*8]
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]
    cmp rbx, rcx
    jg .gt
    je .eq
    ;less than:
    movsx rdx, word [rsi]
    jmp .end
    .eq:
    movsx rdx, word [rsi+2]
    jmp .end
    .gt:
    movsx rdx, word [rsi+4]
    .end:
    lea rsi, [rsi + rdx - 2]
    dispatch
_jcmpc:
    mov rbx, rax
    and rbx, 111b
    mov rbx, [registers+rbx*8]
  
    movsx rax, word [rsi]
    mov rcx, [rsi + rax - 2]
    cmp rbx, rcx
    jg .gt
    je .eq
    ;less than:
    movsx rcx, word [rsi+2]
    jmp .end
    .eq:
    movsx rcx, word [rsi+4]
    jmp .end
    .gt:
    movsx rcx, word [rsi+6]
    .end:
    lea rsi, [rsi + rcx - 2]
    dispatch
_jeqp:
    mov rbx, rax
    and rbx, 111b
    mov rbx, [registers+rbx*8]
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]
    cmp rbx, rcx
    jne .ne
    movsx rbx, word [rsi]
    jmp .end
    .ne:
    movsx rbx, word [rsi+2]
    .end:
    lea rsi, [rsi + rbx - 2]
    dispatch
_jnullp:
    mov rbx, rax
    and rbx, 111b
    mov rbx, [registers+rbx*8]
    and rbx, rbx
    jz .z
    ;nonzero (not null):
    movsx rbx, word [rsi]
    jmp .end
    .z:
    movsx rbx, word [rsi+2]
    .end:
    lea rsi, [rsi + rbx - 2]
    dispatch
_call:
    movsx rax, word [rsi]
    lea rbx, [rsi + rax - 2] ;s[0] location of function
    add rsi, 2
    mov rdi, [rbx] ;rdi number of locals
    mov r8, rdi ;remember how many locals for way later
    add rdi, 11 ;registers saved + td ptr
    shl rdi, 3 ;rdi*8
    ;allocate space for the frame
    push rsi
    push rbx
    push r8
    call malloc
    pop r8
    pop rbx
    pop rsi
    ;save register state
    add rsi, 4 ;because that's where we must jump afterward
    mov r9, [registers+0x08]
    mov r10, [registers+0x10]
    mov r11, [registers+0x18]
    mov r12, [registers+0x20]
    mov [rax+0x00], r9
    mov [rax+0x08], r10
    mov [rax+0x10], r11
    mov [rax+0x18], r12
    mov [rax+0x20], r9
    mov [rax+0x28], r10
    mov [rax+0x30], r11
    mov [rax+0x38], r12
    mov [rax+0x40], rsi
    mov [rax+0x48], rbp
    sub rsi, 4
    mov rdx, rax ; rdx now responsible for new frame
    add rdx, 0x50
    mov rcx, rbx ;preserve location of function
    ;calculate ptr and flags for function header
    or rbx, 2 ; add obj flag
    mov [rdx], rbx ;[rdx] is ptr and flags to function header
    ;copy in locals
    xor rax, rax
    lodsw
    movsx rbx, ax
    lodsw
    ;now rbx is first local, rax is count
    mov rsi, rbx
    shl rsi, 3
    add rsi, rbp ;rsi points to first old local
    add rsi, 0x8 ;rsi points to first param
    mov rdi, rdx ;using rdi for destination of param copy
    add rdi, 8
    ;now copying:
    and rax, rax
    .loop:
        jz .endloop
        movsq
        dec rax
        jmp .loop
    .endloop:
    ;time to set new fp
    mov rbp, rdx
    ;work out how big the function header is
    add r8, 63 ;remember, r8 is number of locals
    shr r8, 6
    shl r8, 3 ;(locals.ceil(64)/64)*8
    add r8, 8
    add r8, rcx ;now r8 points to beginning of function code
    mov rsi, r8 ;jumped.
    dispatch
_ret:
    mov rdi, rbp
    sub rdi, 0x50 ;rdi now points to beginning of register saving
    ;restore registers
    mov r8, [rdi+0x00]
    mov r9, [rdi+0x08]
    mov r10, [rdi+0x10]
    mov r11, [rdi+0x18]
    mov [registers+0x08], r8
    mov [registers+0x10], r9
    mov [registers+0x18], r10
    mov [registers+0x20], r11
    mov rsi, [rdi+0x40]
    mov rbp, [rdi+0x48]
    ;now call free to release frame
    push rsi
    call free
    pop rsi
    ;is there no lower frame?
    and rbp, rbp
    jz end
    ;now ready to dispatch to next instruction
    xor rax, rax
    dispatch
_newp:
    mov rbx, rax
    and rbx, 111b
  
    movsx rax, word [rsi]
    lea rax, [rax + rsi - 2]
    add rsi, 2
    mov rdi, [rax]
    shl rdi, 3
    add rdi, 8
    push rax
    push rbx
    push rsi
    call malloc
    pop rsi
    pop rbx
    mov [registers+rbx*8], rax
    mov rcx, rax
    pop rax
    and rax, ~1111b
    or rax, 10b
    mov [rcx], rax
    xor rax, rax
    dispatch
_newpa:
    mov rbx, rax
    and rbx, 111b
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]

    mov rdi, rcx
    shl rdi, 3 ;*8
    add rdi, 8
    push rbx
    push rcx
    push rsi
    call malloc
    pop rsi
    pop rcx
    pop rbx
    mov [registers+rbx*8], rax
    shl rcx, 4
    or rcx, 1 ;PtrArray
    mov [rax], rcx ;set size and flags
    xor rax, rax
    dispatch
_newa:
    mov rbx, rax
    and rbx, 111b
    mov rcx, rax
    shr rcx, 3
    and rcx, 111b
    mov rcx, [registers+rcx*8]

    mov rdi, rcx
    add rdi, 8
    push rbx
    push rcx
    push rsi
    call malloc
    pop rsi
    pop rcx
    pop rbx
    mov [registers+rbx*8], rax
    shl rcx, 4
    mov [rax], rcx ;set size and flags
    xor rax, rax
    dispatch
_movsc:
    mov rbx, rax
    and rbx, 111b

    movsx rax, word [rsi]
    lea rax, [rsi + rax - 2]
    add rsi, 2
    mov rdi, [rax] ;rdi holds size of string
    add rdi, 8
    push rsi
    push rdi
    push rax
    call malloc
    mov [registers+rbx*8], rax
    mov rdi, rax ;1st argument is destination
    pop rsi ;2nd argument is source
    pop rdx ;3rd arg for memcpy is size
    call memcpy
    pop rsi
    mov rax, [registers+rbx*8]
    mov rbx, [rax]
    shl rbx, 4
    mov [rax], rbx
    xor rax, rax
    
    dispatch
_in:
    mov rbx, rax
    and rbx, 111b
    mov rbx, [registers+rbx*8]
    mov rdi, rbx
    add rdi, 8
    push rsi
    mov rsi, [rbx]
    shr rsi, 4
    call read_line
    pop rsi
    xor rax, rax
    dispatch
_out:
    push rsi
    and rax, 111b
    mov rsi, [registers+rax*8] ;buffer = pi
    mov rdi, 1 ;handle = stdout
    mov rdx, [rsi] ;nbyte = *pi
    shr rdx, 4
    add rsi, 8 ;advance past buffer descriptor
    call write
    pop rsi
    xor rax, rax
    dispatch
_print:
    push rsi
    and rax, 111b
    mov rdi, [registers+rax*8]
    call print_int
    pop rsi
    dispatch
_printp:
    mov rbx, rax
    and rbx, 111b
    mov rbx, [registers+rbx*8]
    mov rdi, rbx
    add rdi, 8
    push rsi
    call println
    pop rsi
    dispatch
_err:
    mov rdi, rsi
    movsx rax, word [rsi]
    add rdi, rax
    call println
    mov rdi, 1
    call exit
    dispatch