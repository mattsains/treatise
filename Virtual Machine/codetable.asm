%macro dispatch 0
        lodsw rax ; rax(IR)=code[rsi(PC)++]
        jmp [rax+vector]
%endmacro

; 0..5 = general purpose
; pc = -1
; fp = -2
; -3...? = scratch registers available
%macro vm_reg 1
        %if %1 = 0
            rbx
        %elif %1 = 1
            rcx
        %elif %1 = 2
            rdx
        %elif %1 = 3
            r8
        %elif %1 = 4
            r9
        %elif %1 = 5
            r10
        %elif %1 = -1
            rsi
        %elif %1 = -2
            rbp
        %elif %1 = -3
            r11
        %elif %1 = -4
            r12
        %elif %1 = -5
            r13
        %else
            %error "Invalid register argument to vm_reg"
        %endif
%endmacro

;; This macro is for when the operation is identical to the x86's
%macro vm_simple 3
        %[%1]_%[%2]_%[%3]:
           %1 vm_reg(%2), vm_reg(%3)
           dispatch
%endmacro

;; This macro is for when the operation is almost identical to the x86's
%macro vm_simple 4
        %[%1]_%[%3]_%[%4]:
           %2 vm_reg(%3), vm_reg(%4)
           dispatch
%endmacro

;;; Start of code table macros
%define vm_add(a,b) vm_simple(add, a, b)

%macro vm_add_const 1
        %warn "Not implemented yet"
%endmacro

%define vm_sub(a,b) vm_simple(sub, a, b)

%macro vm_sub_const 1
        %warn "Not implemented yet"
%endmacro

%macro vm_sub_const2 1
        %warn "Not implemented yet"
%endmacro

%define vm_mul(a,b) vm_simple(mul, imul, a, b)

%macro vm_mul_const 1
        %warn "Not implemented yet"
%endmacro

%macro vm_div 2
        div_%[%1]_%[%2]:
           mov rax, vm_reg(%1) ; mov numerator to rax (no saving needed)
           mov vm_reg(-3), rdx ;save rdx for clear
           xor rdx, rdx
           idiv vm_reg(%2) ; rdx:rax / arg; rax=result, rdx=remainder
           mov vm_reg(%1), rax ;result -> arg1
           mov vm_reg(0), rdx ; remain -> reg0
           mov rdx, vm_reg(-3) ;restore rdx
           dispatch
%endmacro

;; More const divs but I don't feel like writing macro stubs for them

%define vm_and(a,b) vm_simple(and, a, b)

;; todo: const

%define vm_or(a,b) vm_simple(or, a, b)

;; todo: const

%define vm_xor(a,b) vm_simple(xor, a, b)


;; table of offsets (labels)
vector:
   %assign r1 0
        %rep 6
              %assign r2 0
              %rep 6
                   add_%[r1]_%[r2]
                   %assign r2 r2+1
              %endrep
              %assign r1 r1+1
        %endrep

;; table of instruction macro instances
code:
        %assign r1 0
        %rep 6
              %assign r2 0
              %rep 6
                   vm_add r1, r2
                   %assign r2 r2+1
              %endrep
              %assign r1 r1+1
        %endrep
        
