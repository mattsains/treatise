function fib
  int output
  
  movc r1, 0
  movc r2, 1
  setl fib.output, r1
  call i_to_s, fib.output, 1
  out r0
  setl fib.output, r2
  call i_to_s, fib.output, 1
  out r0
  .loop:
  mov r3, r1
  add r3, r2
  mov r1, r2
  mov r2, r3
  ;print result
  setl fib.output, r3
  call i_to_s, fib.output, 1
  out r0
  jmp .loop
  ;never ends for performance reasons

%include ../stdlib.asm