function reverse
  movc r1, 20
  newa r0, r1
  in r0
  
  movc r1, 0
  .floop:
  getb r3, r0, r1
  jcmpc r3, 0, .fend, .fend, $
  addc r1, 1
  jmp .floop
  .fend:
  addc r1, -1 ;r1 length -1 of string
  movp r4, r0
  mov r3, r1
  divc r1, 2
  movp r0, r4
  
  movc r2, 0
  .loop:
  jcmp r2, r1, $, .end, .end
  getb r5, r0, r2
  getb r4, r0, r3
  setb r0, r2, r4
  setb r0, r3, r5
  addc r2, 1
  addc r3, -1
  jmp .loop
  .end:
  out r0
ret