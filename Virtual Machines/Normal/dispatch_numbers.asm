add_offset equ 0
addc_offset equ 36
sub_offset equ 42
subc_offset equ 78
csub_offset equ 84
mul_offset equ 90
mulc_offset equ 126
div_offset equ 132
divc_offset equ 168
and_offset equ 174
andc_offset equ 210
or_offset equ 216
orc_offset equ 252
xor_offset equ 258
shl_offset equ 294
shlc_offset equ 330
cshl_offset equ 336
shr_offset equ 342
shrc_offset equ 378
cshr_offset equ 384
sar_offset equ 390
sarc_offset equ 426
csar_offset equ 432
mov_offset equ 438
movp_offset equ 474
movc_offset equ 510
null_offset equ 516
jmp_offset equ 522
jmpf_offset equ 523
switch_offset equ 524
jcmp_offset equ 530
jcmpc_offset equ 566
jeqp_offset equ 572
jnullp_offset equ 608
alloc_offset equ 614
in_offset equ 620
out_offset equ 626
err_offset equ 632
%macro dispatch 0
    lodsw
.add_dispatch:
   cmp rax, addc_offset
   jge .addc_dispatch
   sub rax, add_offset
   jmp add
.addc_dispatch:
   cmp rax, sub_offset
   jge .sub_dispatch
   sub rax, addc_offset
   jmp addc
.sub_dispatch:
   cmp rax, subc_offset
   jge .subc_dispatch
   sub rax, sub_offset
   jmp sub
.subc_dispatch:
   cmp rax, csub_offset
   jge .csub_dispatch
   sub rax, subc_offset
   jmp subc
.csub_dispatch:
   cmp rax, mul_offset
   jge .mul_dispatch
   sub rax, csub_offset
   jmp csub
.mul_dispatch:
   cmp rax, mulc_offset
   jge .mulc_dispatch
   sub rax, mul_offset
   jmp mul
.mulc_dispatch:
   cmp rax, div_offset
   jge .div_dispatch
   sub rax, mulc_offset
   jmp mulc
.div_dispatch:
   cmp rax, divc_offset
   jge .divc_dispatch
   sub rax, div_offset
   jmp div
.divc_dispatch:
   cmp rax, and_offset
   jge .and_dispatch
   sub rax, divc_offset
   jmp divc
.and_dispatch:
   cmp rax, andc_offset
   jge .andc_dispatch
   sub rax, and_offset
   jmp and
.andc_dispatch:
   cmp rax, or_offset
   jge .or_dispatch
   sub rax, andc_offset
   jmp andc
.or_dispatch:
   cmp rax, orc_offset
   jge .orc_dispatch
   sub rax, or_offset
   jmp or
.orc_dispatch:
   cmp rax, xor_offset
   jge .xor_dispatch
   sub rax, orc_offset
   jmp orc
.xor_dispatch:
   cmp rax, shl_offset
   jge .shl_dispatch
   sub rax, xor_offset
   jmp xor
.shl_dispatch:
   cmp rax, shlc_offset
   jge .shlc_dispatch
   sub rax, shl_offset
   jmp shl
.shlc_dispatch:
   cmp rax, cshl_offset
   jge .cshl_dispatch
   sub rax, shlc_offset
   jmp shlc
.cshl_dispatch:
   cmp rax, shr_offset
   jge .shr_dispatch
   sub rax, cshl_offset
   jmp cshl
.shr_dispatch:
   cmp rax, shrc_offset
   jge .shrc_dispatch
   sub rax, shr_offset
   jmp shr
.shrc_dispatch:
   cmp rax, cshr_offset
   jge .cshr_dispatch
   sub rax, shrc_offset
   jmp shrc
.cshr_dispatch:
   cmp rax, sar_offset
   jge .sar_dispatch
   sub rax, cshr_offset
   jmp cshr
.sar_dispatch:
   cmp rax, sarc_offset
   jge .sarc_dispatch
   sub rax, sar_offset
   jmp sar
.sarc_dispatch:
   cmp rax, csar_offset
   jge .csar_dispatch
   sub rax, sarc_offset
   jmp sarc
.csar_dispatch:
   cmp rax, mov_offset
   jge .mov_dispatch
   sub rax, csar_offset
   jmp csar
.mov_dispatch:
   cmp rax, movp_offset
   jge .movp_dispatch
   sub rax, mov_offset
   jmp mov
.movp_dispatch:
   cmp rax, movc_offset
   jge .movc_dispatch
   sub rax, movp_offset
   jmp movp
.movc_dispatch:
   cmp rax, null_offset
   jge .null_dispatch
   sub rax, movc_offset
   jmp movc
.null_dispatch:
   cmp rax, jmp_offset
   jge .jmp_dispatch
   sub rax, null_offset
   jmp null
.jmp_dispatch:
   cmp rax, jmpf_offset
   jge .jmpf_dispatch
   sub rax, jmp_offset
   jmp jmp
.jmpf_dispatch:
   cmp rax, switch_offset
   jge .switch_dispatch
   sub rax, jmpf_offset
   jmp jmpf
.switch_dispatch:
   cmp rax, jcmp_offset
   jge .jcmp_dispatch
   sub rax, switch_offset
   jmp switch
.jcmp_dispatch:
   cmp rax, jcmpc_offset
   jge .jcmpc_dispatch
   sub rax, jcmp_offset
   jmp jcmp
.jcmpc_dispatch:
   cmp rax, jeqp_offset
   jge .jeqp_dispatch
   sub rax, jcmpc_offset
   jmp jcmpc
.jeqp_dispatch:
   cmp rax, jnullp_offset
   jge .jnullp_dispatch
   sub rax, jeqp_offset
   jmp jeqp
.jnullp_dispatch:
   cmp rax, alloc_offset
   jge .alloc_dispatch
   sub rax, jnullp_offset
   jmp jnullp
.alloc_dispatch:
   cmp rax, in_offset
   jge .in_dispatch
   sub rax, alloc_offset
   jmp alloc
.in_dispatch:
   cmp rax, out_offset
   jge .out_dispatch
   sub rax, in_offset
   jmp in
.out_dispatch:
   cmp rax, err_offset
   jge .err_dispatch
   sub rax, out_offset
   jmp out
.err_dispatch:
   sub rax, err_offset
   jmp err
%endmacro
