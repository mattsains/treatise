function primes
  int output

  movc r1, 1

  .outloop:
  addc r1, 1
  mov r2, r1
  .loop:
  addc r2, -1
  
  jcmpc r2, 1, .prime, .prime, $ ;if r2 1, prime. else keep going
  mov r3, r1
  div r1, r2
  mov r1, r3
  jcmpc r0, 0, .outloop, .outloop, .loop
  
  .prime:
  mov r4, r0
  setl primes.output, r1
  call i_to_s, primes.output, 1
  out r0
  mov r0, r4
  jmp .outloop
  ;never returns for perf reasons

%include ../stdlib.asm