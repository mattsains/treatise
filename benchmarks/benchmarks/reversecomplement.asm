function reversecomplement
  ptr spillpairs
  ptr spillbuffer
  
  movc r0, 128
  newa r1, r0
  ;;;; begin fill array
  movc r0, 'A'
  movc r2, 'T'
  setb r1, r0, r2
  movc r0, 'a'
  movc r2, 'T'
  setb r1, r0, r2
  movc r0, 'C'
  movc r2, 'G'
  setb r1, r0, r2
  movc r0, 'c'
  movc r2, 'G'
  setb r1, r0, r2
  movc r0, 'G'
  movc r2, 'C'
  setb r1, r0, r2
  movc r0, 'g'
  movc r2, 'C'
  setb r1, r0, r2
  movc r0, 'T'
  movc r2, 'A'
  setb r1, r0, r2
  movc r0, 't'
  movc r2, 'A'
  setb r1, r0, r2
  movc r0, 'U'
  movc r2, 'A'
  setb r1, r0, r2
  movc r0, 'u'
  movc r2, 'A'
  setb r1, r0, r2
  movc r0, 'M'
  movc r2, 'K'
  setb r1, r0, r2
  movc r0, 'm'
  movc r2, 'K'
  setb r1, r0, r2
  movc r0, 'R'
  movc r2, 'Y'
  setb r1, r0, r2
  movc r0, 'r'
  movc r2, 'Y'
  setb r1, r0, r2
  movc r0, 'W'
  movc r2, 'W'
  setb r1, r0, r2
  movc r0, 'w'
  movc r2, 'W'
  setb r1, r0, r2
  movc r0, 'S'
  movc r2, 'S'
  setb r1, r0, r2
  movc r0, 's'
  movc r2, 'S'
  setb r1, r0, r2
  movc r0, 'Y'
  movc r2, 'R'
  setb r1, r0, r2
  movc r0, 'y'
  movc r2, 'R'
  setb r1, r0, r2
  movc r0, 'K'
  movc r2, 'M'
  setb r1, r0, r2
  movc r0, 'k'
  movc r2, 'M'
  setb r1, r0, r2
  movc r0, 'V'
  movc r2, 'B'
  setb r1, r0, r2
  movc r0, 'v'
  movc r2, 'B'
  setb r1, r0, r2
  movc r0, 'H'
  movc r2, 'D'
  setb r1, r0, r2
  movc r0, 'h'
  movc r2, 'D'
  setb r1, r0, r2
  movc r0, 'D'
  movc r2, 'H'
  setb r1, r0, r2
  movc r0, 'd'
  movc r2, 'H'
  setb r1, r0, r2
  movc r0, 'B'
  movc r2, 'V'
  setb r1, r0, r2
  movc r0, 'b'
  movc r2, 'V'
  setb r1, r0, r2
  movc r0, 'N'
  movc r2, 'N'
  setb r1, r0, r2
  movc r0, 'n'
  movc r2, 'N'
  setb r1, r0, r2
  ;;;; end fill array
  movc r0, 256
  newa r2, r0
  movc r0, 61
  newa r3, r0
  movc r0, 524288000
  newa r4, r0
  setlp .spillpairs, r1
  ; r1: i (to be set)
  ; r2: buffer[]
  ; r3: outbuffer[]
  ; r4: sequence[]
  movc r1, 0
  .loop:
  in r2
  ;test for headings and end of file
  movc r5, 0
  getb r0, r2, r5 ;r0=buffer[0]
  jcmpc r0, '>', $, .heading, $
  jcmpc r0, 0, $, .heading, $ ;\0
  ;heading goes off somewhere and rejoins at .loop
  setlp .spillbuffer, r3
  getlp r3, .spillpairs
  movc r0, 0
  ; .buffer: outbuffer[]
  ; r0: j
  ; r1: i
  ; r2: buffer[]
  ; r3: pairs[]
  ; r4: sequence[]
  ; r5: spare
  .seqloop:
  getb r5, r2, r0
  jcmpc r5, 0, $, .seqend, $
  getb r5, r3, r5
  add r1, r0
  setb r4, r1, r5
  sub r1, r0
  addc r0, 1
  jmp .seqloop
  .seqend:
  add r1, r0
  jmp .loop

  

  .heading:
  ;need a spare register
  setlp .spillbuffer, r2
  jcmpc r1, 0, $, .afterprint, $
  ;for j=i:
  mov r5, r1 ;j=i
  addc r5, -1
  .jloop:
  jcmpc r5, 0, .jend, $, $
  ;for k=0
  movc r0, 0
  .kloop:
  jcmpc r0, 60, $, .kend, .kend
  ; r2: spare
  ; r3: outbuffer
  ; r4: sequence
  ; r5: j
  ; r0: k
  ; r1: i
  jcmp r5, r0, $, .jkelse, .jkelse
  movc r2, 0
  setb r3, r0, r2 ;outbuffer[k]='\0'
  jmp .jkend
  .jkelse:
  mov r2, r5
  sub r2, r0 ;r2 = j-k
  getb r2, r4, r2 ;r2=sequence[j-k]
  setb r3, r0, r2 ;outbuffer[k]=^
  .jkend:
  addc r0, 1 ;for(_,_,k++)
  jmp .kloop
  .kend:
  ; r0: spare
  movc r0, 60
  movc r2, 0
  setb r3, r0, r2 ;outbuffer[60]='\0'
  printp r3
  addc r5, -60 ;for(_,_,j-=60)
  jmp .jloop
  .jend:
  movc r1, 0
  .afterprint:
  getlp r2, .spillbuffer
  ; r2: buffer
  ; r0: spare
  movc r0, 0
  getb r0, r2, r0 ;buffer[0]
  jcmpc r0, '>', .end, $, .end
  printp r2
  jmp .loop

  .end:
ret