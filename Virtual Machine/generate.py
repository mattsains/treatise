# 0..5 = general purpose
# pc = -1
# fp = -2
# scratch registers = -3..-5
def vm_reg(i):
    return (['rbx','rcx','rdx','r8','r9','r10','r13','r12','r11','rbp','rsi'])[i]

def dispatch():
    return ('    ;dispatch \n'
    '    lodsw \n' # rax(IR)=code[rsi(PC)++]
    '    mov rax, [vector+rax] \n'
    '    jmp rax')

# This is for when the operation is identical to the x86's
def vm_simple(opcode, r1, r2):
    return (opcode+'_'+str(r1)+'_'+str(r2)+': \n'
    '    '+opcode+' '+vm_reg(r1)+', '+vm_reg(r2)+'\n'+
    dispatch())

# This is for when the operation is almost identical to the x86's
def vm_quite_simple(vm_opcode, real_opcode, r1, r2):
    return (vm_opcode+'_'+r1+'_'+r2+': \n'
    '    '+real_opcode+' '+vm_reg(r1)+', '+ vm_reg(r2)+' \n'+
    dispatch())


# Start of code table macros
def vm_add(r1, r2):
    return vm_simple('add', r1, r2)

def vm_add_const(r1):
    raise("Not implemented yet")

def vm_sub(r1, r2): vm_simple('sub', r1, r2)

def vm_sub_const(r1):
    raise("Not implemented yet")

def vm_sub_const2(r1):
    raise("Not implemented yet")

def vm_mul(r1,r2): return vm_simple('mul', 'imul', r1, r2)

def vm_mul_const(r1):
    raise("Not implemented yet")

def vm_div(r1, r2):
    rr0 = vm_reg(0)
    rr1 = vm_reg(r1)
    rr2 = vm_reg(r2)
    rrs = vm_reg(-3)
    return ('div_'+str(r1)+'_'+str(r2)+': \n'
    '    mov rax, '+rr1+' \n' #mov numerator to rax (no saving needed)
    '    mov '+rrs+', rdx \n' #save rdx for clear
    '    cqo \n'
    '    idiv '+rr2+' \n' # rdx:rax / arg; rax=result, rdx=remainder
    '    mov '+rr1+', rax \n' #result -> arg1
    '    mov '+rr0+', rdx \n' #remain -> reg0
    '    mov rdx, '+rrs+' \n'+ #restore rdx
    dispatch())


# More const divs but I don't feel like writing macro stubs for them

def vm_and(r1,r2): return vm_simple('and', r1, r2)

# todo: const

def vm_or(r1,r2): return vm_simple('or', r1, r2)

# todo: const

def vm_xor(r1,r2):return  vm_simple('xor', r1, r2)

opcode_funcs = [vm_add, vm_div]

# table of offsets (labels)
print 'vector: '
for func in opcode_funcs:
    for r1 in range(0,6):
        for r2 in range(0,6):
            print 'dw add_'+str(r1)+'_'+str(r2)

# table of instruction macro instances
print 'code: '
for func in opcode_funcs:
    for r1 in range(0,6):
        for r2 in range(0,6):
            print func(r1, r2)
