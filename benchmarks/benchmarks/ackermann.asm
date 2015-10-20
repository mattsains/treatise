function ackermann
  int m
  int n
  ;hardcoded inputs
  movc r0, 4 ;m
  movc r1, 1 ;n
  setl .m, r0
  setl .n, r1
  call A, 0, 2
  ;r0 now has the result of the ackermann function
  ;should be 65533 for (4,1)
  ; takes about 3 minutes
  print r0
ret
  
function A
  int m
  int n
  
  getl r1, A.m
  getl r2, A.n
  
  jcmpc r1, 0, .c1, .c1, .c23
  .c1:
  addc r2, 1
  mov r0, r2
  ret
  .c23:
  jcmpc r2, 0, .c2, .c2, .c3
  .c2:
  addc r1, -1
  setl A.m, r1
  movc r2, 1
  setl A.n, r2
  call A, A.m, 2
  ret
  .c3:
  addc r2, -1
  setl A.n, r2
  call A, A.m, 2
  ;r0 now result
  setl A.n, r0
  addc r1, -1
  setl A.m, r1
  call A, A.m, 2
ret

%include ../stdlib.asm