; Calculates the sum of all multiples of 3 or 5 under 1000
; This program should end with r5 = 0x38ed0 = 233168
function mul35
  int output

  movc r1, 1
  movc r5, 0

  .loop:
  mov r2, r1
  divc r1, 3
  mov r1, r2
  jcmpc r0, 0, .acc, .acc, $
  divc r1, 5
  mov r1, r2
  jcmpc r0, 0, .acc, .acc, .reject
  .acc:
  add r5, r1
  .reject:
  addc r1, 1
  
  jcmpc r1, 1000, .loop, $, $

  ;end of loop
  setl mul35.output, r5
  call i_to_s, mul35.output, 1
  out r0
  ret

%include ../stdlib.asm