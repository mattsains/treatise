function fasta
  ptr HomoSapiens
  int HomoSapiens_length
  int HomoSapiens_n
  ptr IUB
  int IUB_length
  int IUB_n
  ptr ALU
  int ALU_length
  int ALU_n

  movc r5, 42 ;seed for RNG

  movc r0, 4
  setl .HomoSapiens_length, r0
  newpa r1, r0
  setlp .HomoSapiens, r1
  movc r0, 0
  movc r2, 'a'
  movc r3, 3030
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 1
  movc r2, 'c'
  movc r3, 1980
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 2
  movc r2, 'g'
  movc r3, 1975
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 3
  movc r2, 't'
  movc r3, 3015
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  
  movc r0, 15
  setl .IUB_length, r0
  newpa r1, r0
  setlp .IUB, r1
  movc r0, 0
  movc r2, 'a'
  movc r3, 2700
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 1
  movc r2, 'c'
  movc r3, 1200
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 2
  movc r2, 'g'
  movc r3, 1200
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 3
  movc r2, 't'
  movc r3, 2700
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 4
  movc r2, 'B'
  movc r3, 200
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 5
  movc r2, 'D'
  movc r3, 200
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 6
  movc r2, 'H'
  movc r3, 200
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 7
  movc r2, 'K'
  movc r3, 200
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 8
  movc r2, 'M'
  movc r3, 200
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 9
  movc r2, 'N'
  movc r3, 200
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 10
  movc r2, 'R'
  movc r3, 200
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 11
  movc r2, 'S'
  movc r3, 200
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 12
  movc r2, 'V'
  movc r3, 200
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 13
  movc r2, 'W'
  movc r3, 200
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4
  movc r0, 14
  movc r2, 'Y'
  movc r3, 200
  newp r4, Frequency
  setm r4, Frequency.c, r2
  setm r4, Frequency.p, r3
  setap r1, r0, r4

  
  movc r0, 287
  setl .ALU_length, r0

  movsc r1, alu_str
  setlp .ALU, r1

  call makeCumulative, .HomoSapiens, 2
  call makeCumulative, .IUB, 2

  ;">Homosapiens alu"
  movsc r1, homo_alu_str
  printp r1

  movc r0, 50000000
  setl .ALU_n, r0
  call makeRepeatFasta, .ALU, 3

  ;">TWO IUB ambiguity codes"
  movsc r1, iub_code_str
  printp r1

  movc r0, 75000000
  setl .IUB_n, r0
  call makeRandomFasta, .IUB, 3

  ;">THREE Homo sapiens frequency"
  movsc r1, homo_freq_str
  printp r1
  
  movc r0, 125000000
  setl .HomoSapiens_n, r0
  call makeRandomFasta, .HomoSapiens, 3
ret

alu_str:
  ds "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGGGAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGACCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAATACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCAGCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGGAGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCCAGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA"
homo_alu_str:
  ds ">ONE Homo sapiens alu:"
iub_code_str:
  ds ">TWO IUB ambiguity codes"
homo_freq_str:
  ds ">THREE Homo sapiens frequency"
  
; Important: Preserve r5, it is a global used in this function
function random
  int max

  mulc r5, 3877
  addc r5, 29573
  divc r5, 139968
  mov r5, r0

  getl r1, .max
  mul r1, r5
  divc r1, 139968000000
  mov r0, r1
ret

object Frequency
  int c
  int p

function makeCumulative
  ptr frequencies
  int length

  getlp r0, .frequencies
  getl r1, .length


  movc r2, 0 ;total
  movc r3, 0 ;i

  .loop:
  jcmp r3, r1, $, .end, .end
  getap r4, r0, r3
  getm r4, r4, Frequency.p
  add r2, r4
  getap r4, r0, r3
  setm r4, Frequency.p, r2
  addc r3, 1
  jmp .loop
  .end:
ret

function selectRandom
  ptr frequencies
  int length
  int c_10000000000

  movc r0, 10000000000
  setl .c_10000000000, r0
  call random, .c_10000000000, 1
  mov r3, r0 ;r3 = r
  getlp r0, .frequencies
  getl r1, .length

  movc r2, 0 ;i

  .loop:
  jcmp r2, r1, $, .lend, .lend

  getap r4, r0, r2
  getm r4, r4, Frequency.p
  jcmp r3, r4, $, .continue, .continue
  getap r4, r0, r2
  getm r0, r4, Frequency.c
  ret
  .continue:
  addc r2, 1
  jmp .loop
  .lend:
  addc r1, -1
  geta r0, r0, r1
  getm r0, r0, Frequency.c
ret

function makeRandomFasta
  ptr frequencies
  int length
  int n

  int spill

  movc r0, 1024
  newa r1, r0 ;buffer

  movc r0, 0 ;index

  mov r2, r0 ;m

  getl r3, .n

  .wloop:
  jcmpc r3, 0, .wloopend, .wloopend, $

  jcmpc r3, 60, $, .else, .else
  mov r2, r3
  jmp .ifend
  .else:
  movc r2, 60
  .ifend:

  setl .spill, r3
  movc r4, 0
  .floop:
  jcmp r4, r2, $, .fend, .fend
  mov r3, r0 ;index in r3 temporarily
  call selectRandom, .frequencies, 2
  setb r1, r3, r0
  mov r0, r3
  addc r0, 1
  addc r4, 1
  jmp .floop
  .fend:
  getl r3, .spill

  jcmpc r0, 964, .if2else, $, $
  movc r4, 0
  setb r1, r0, r4
  printp r1
  movc r0, 0
  jmp .if2end
  .if2else:

  jcmpc r3, 60, .if2end, .if2end, $
  movc r4, 0xa ;\n
  setb r1, r0, r4
  addc r0, 1
  .if2end:

  addc r3, -60
  jmp .wloop
  
  .wloopend:

  jcmpc r0, 0, $, .end, $
  movc r3, 0
  setb r1, r0, r3
  printp r1
  .end:
ret

function makeRepeatFasta
  ptr alu
  int length
  int n

  int spill_k
  int spill_m
  
  movc r0, 1024
  newa r1, r0 ;buffer

  movc r0, 0 ;index
  mov r2, r0 ;m
  getl r3, .n

  setl .spill_k, r0

  .wloop:
  jcmpc r3, 0, .wloopend, .wloopend, $

  jcmpc r3, 60, $, .else, .else
  mov r2, r3
  jmp .ifend
  .else:
  movc r2, 60
  .ifend:

  movc r4, 0
  getl r3, .spill_k
  .forloop:
  jcmp r4, r2, $, .forend, .forend
  setl .spill_m, r2
  getl r2, .length
  jcmp r3, r2, .if2end, $, .if2end
  movc r3, 0
  .if2end:
  getlp r2, .alu
  getb r2, r2, r3
  setb r1, r0, r2
  addc r0, 1
  addc r3, 1
  addc r4, 1
  getl r2, .spill_m
  jmp .forloop
  .forend:
  setl .spill_k, r3
  getl r3, .n
  ;setlp .spill_alu, r2 ;not needed because it doesn't change
  getl r2, .spill_m
  ; r0 - index
  ; r1 - buffer
  ; r2 - m
  ; r3 - n
  ; r4 - spare

  jcmpc r0, 964, .if3else, $, $
  movc r4, 0
  setb r1, r0, r4
  printp r1
  movc r0, 0
  jmp .if3end
  .if3else:

  jcmpc r3, 60, .if3end, .if3else, $
  movc r4, 0xa ;\n
  setb r1, r0, r4
  addc r0, 1
  .if3end:
  
  addc r3, -60
  setl .n, r3
  jmp .wloop

  .wloopend:

  jcmpc r0, 0, $, .end, $
  movc r3, 0
  setb r1, r0, r3
  printp r1
  .end:
ret