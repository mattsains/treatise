;NB checksum is wrong because I didn't use their weird permutaiton order
;Code still does the same thing though so that's fine
;Algorithm is as follows:
; let max be 0 
; let count be 0
; Go through all permutations of 7 integers from 1 to 7
;  e.g. {2,3,4,1,5,6,7}
;  flip the first 2 -> {3,2,4,1,5,6,7}, count++
;  flip the first 3 -> {4,2,3,1,5,6,7}, count++
;  flip the first 4 -> {1,3,2,4,5,6,7}, count++
;  if (count > max)
;     max = count
;  print max

function fannkuch
  int max
  ptr buffer
  ptr buffer2
  int length
  int checksum
  int sign
  ;r1, r2 - indexes of elements to be swapped
  ;r4 - count
  ;p0 - buffer
  ;set up buffer:
  movc r5, 11
  setl fannkuch.length, r5
  newa r0, r5
  newa r1, r5
  setlp fannkuch.buffer2, r1
  addc r5, -1

  .setup:  
  setb r0, r5, r5
  addc r5, -1
  jcmpc r5, 0, $, .setup, .setup  
  
  movc r3, 1
  setl fannkuch.sign, r3 
  movc r3, 0
  setl fannkuch.max, r3 ;let max be 0
  setl fannkuch.checksum, r3 ;let checksum be 0

  movc r4, 0

  ;save buffer
  setlp fannkuch.buffer, r0
  ;copy it and mess with the copy only
  call buffercopy, fannkuch.buffer, 3
  jmp .pancake
  .inputloop:
  getl r3, fannkuch.max 
  jcmp r3, r4, $, .notbigger, .notbigger ;if count > max
  setl fannkuch.max, r4 ;then new max found
  .notbigger:
  ;checksum code - checksum not correct because permutation order is wrong... it matters not really
  ;this still does the same work 
  getl r3 fannkuch.sign
  mul r4, r3
  mulc r3, -1
  setl fannkuch.sign, r3
  getl r3 fannkuch.checksum
  add r3, r4
  setl fannkuch.checksum, r3
  ;next permutation  
  call permute, fannkuch.buffer, 3
  ;out p0 
  setlp fannkuch.buffer, r0
  call buffercopy, fannkuch.buffer, 3
  movc r4, 0 ;reset count to 0 for new input
  getb r3, r0, r4 ;check if we are done with perms
  jcmpc r3, 127, $, .done, $ ;lt should never happen

  .pancake:
  movc r3, 0
  getb r2, r0, r3
  jcmpc r2, 0, $, .inputloop, $; if we read 0 then we are done (don't inc count)
  movc r1, 0
  .flip:
  jcmp r1, r2, $, .inccount, .inccount
  getb r3, r0, r2
  getb r5, r0, r1
  setb r0, r2, r5
  setb r0, r1, r3
  addc r1, 1
  addc r2, -1 
  jmp .flip 
  .inccount:
  addc r4, 1
  jmp .pancake

  .done:
  getl r0, fannkuch.max
  print r0
  getl r0, fannkuch.checksum
  print r0
ret

  ; generate permutations based on lexicographic order
  ; takes a buffer as input and returns the next permutation,
  ; if done returns a buffer with first character set to 127
function permute
  ptr buffer
  ptr buffer2 ;along for the ride because of weird call mechanism
  int length
  int start

  getlp r0, permute.buffer
  getl r3, permute.length ;k + 2
  mov r2, r3
  mov r1, r2
  addc r3, -1 
  addc r1, -1
  ;r3 = last index
  ;r1 = last index
  ;r2 = last index + 1

  .largekloop:
  addc r1, -1 ; k
  addc r2, -1 ; k + 1
  jcmpc r1, 0, .doneperms, $, $ ;check if we are done
  getb r4, r0, r1 ;buffer[k]
  getb r5, r0, r2 ;buffer[k + 1]
  jcmp r4, r5, $, .largekloop, .largekloop
  ;permute.start = k + 1
  ;r4 = buffer[k]
  ;r3 = last index
  ;r2 = k + 1
  setl permute.start, p2 
  
  .largelloop:
  mov r1, r2 ;store current l
  .largelloop2:
  jcmp r2, r3, $, .swaprotate, $ ;gt should never happen
  addc r2, 1
  getb r5, r0, r2
  jcmp r5, r4, .largelloop2, .largelloop2, .largelloop
  ;r1 = l

  .doneperms:
  movc r2, 127
  movc r1, 0
  setb r0, r1, r2 ;buffer[0] = 127
  jmp .end

  .swaprotate:
  getl r2, permute.start
  addc r2, -1 ;k
  ;swap buffer[k] and buffer[l]
  getb r4, r0, r2 ;r4 = buffer[k]
  getb r5, r0, r1 ;r5 = buffer[l]
  setb r0, r2, r5 ;buffer[k] = r5
  setb r0, r1, r4 ;buffer[l] = r4
  setlp permute.buffer, r0
  setl permute.length, r3
  call rotate, permute.buffer, 4
  .end:
ret

function rotate
  ptr buffer
  ptr buffer2
  int lastindex
  int start
  getlp r5, rotate.buffer
  getl r2, rotate.lastindex ;end
  mov r3, r2
  addc r3, 1 ;end + 1
  getl r1, rotate.start ;start
  sub r3, r1
  divc r3, 2 ;length/2
  movp r0, r5
  .rotloop:
  jcmpc r3, 0, .end, .end, $
  addc r3, -1
  getb r4, r0, r2
  getb r5, r0, r1
  ;swap
  setb r0, r1, r4
  setb r0, r2, r5
  addc r2, -1
  addc r1, 1
  jmp .rotloop
  .end:
ret

%include ../stdlib.asm