  ;pipe the output to output.pbm and open with an image viewer. you'll know when it works
  ;only problem is it takes about a year to complete for me. not sure if code or VM mistake
function mandel
  int width
  int height
  int maxiter
  int limit
  int index
  int size
  int bits
  int Ci
  int Cr
  int Tr
  int i
  int x
  int y
  int temp
  ptr output

  movc r4, 16000
  movc r2, 16000 ;so we can edit this parameter
  setl mandel.height, r4
  setl mandel.width, r2
  movc r3, 50
  setl mandel.maxiter, r3
  addc r2, 7 ;width + 7
  divc r2, 8 ;(width + 7)/8
  mul r2, r4 ;(width + 7)/8 * height 
  addc r2, 15 ;(width + 7)/8 * height + 15
  setl mandel.size, r2
  mov r0, r2

  movc r3, 4
  movc r5, 1000 ;r5 is SCALE
  mul r3, r5 ;4 * SCALE
  mul r3, r5 ;4 * SCALE * SCALE
  setl mandel.limit, r3
  

  ;;Add pbm format
  newa p3, r0
  movc r1, 0 ;r1 is index for now
  movc r2, 'P'
  setb p3, r1, r2
  addc r1, 1
  movc r2, '4'
  setb p3, r1, r2
  addc r1, 1
  movc r2, 10
  setb p3, r1, r2
  addc r1, 1
  movc r2, '1'
  setb p3, r1, r2
  addc r1, 1
  movc r2, '6'
  setb p3, r1, r2
  addc r1, 1
  movc r2, '0'
  setb p3, r1, r2
  addc r1, 1
  movc r2, '0'
  setb p3, r1, r2
  addc r1, 1
  movc r2, '0'
  setb p3, r1, r2
  addc r1, 1
  movc r2, 10
  setb p3, r1, r2
  addc r1, 1
  movc r2, '1'
  setb p3, r1, r2
  addc r1, 1
  movc r2, '6'
  setb p3, r1, r2
  addc r1, 1
  movc r2, '0'
  setb p3, r1, r2
  addc r1, 1
  movc r2, '0'
  setb p3, r1, r2
  addc r1, 1
  movc r2, '0'
  setb p3, r1, r2
  addc r1, 1
  movc r2, 10
  setb p3, r1, r2
  addc r1, 1
  ;save index and output
  setl mandel.index, r1
  setlp mandel.output, p3


  ;most used vars look like these:
  ;===============================
  ;I'll mostly keep:
  ;r0 for whatever
  ;x/i in r1
  ;y/whatever in r2
  ;Zr in r3 
  ;Zi in r4
  ;SCALE in r5 (there right now)

  movc r2, 0

  .yloop:
  getl r0 mandel.height
  jcmp r2, r0, $, .yend, .yend
  
  movc r0, 0
  setl mandel.bits, r0
  ;r1, r3 and r4 are free to use at this point (phew)
  movc r1, 2
  mul r1, r5 ;2*SCALE
  mul r1, r2 ;2*SCALE*y
  getl r3, mandel.height
  div r1, r3
  sub r1, r5 ;2*SCALE*y/height - SCALE
  setl mandel.Ci, r1

  ;save y
  setl mandel.y, r2

  ;restore x = 0
  movc r1, 0
  .xloop:
  getl r0 mandel.width
  jcmp r1, r0, $, .xend, .xend

  
  movc r3, 2
  mul r3, r5 ;2*SCALE
  mul r3, r1 ;2*SCALE*x
  div r3, r0 ;2*SCALE*x/width
  mov r2, r5
  divc r2, 2 ;SCALE/2
  add r2, r5 ;SCALE/2 + SCALE
  sub r3, r2 ;2*SCALE*x/width - (SCALE/2 + SCALE)
  setl mandel.Cr, r3
  movc r3, 0
  movc r4, 0

  ;save x
  setl mandel.x, r1
  getl r1 mandel.maxiter ;r1 = i = maxiter

  getl r0 mandel.bits
  shlc r0, 1
  setl mandel.bits, r0

  .doloop:
  movc r2, 2
  mul r2, r3
  mul r2, r4
  div r2, r5
  mov r0, r2
  getl r2 mandel.Ci
  add r0, r2
  setl mandel.temp, r0  
  ;i can safely square Zi and Zr 
  mul r3, r3
  mul r4, r4
  mov r2, r3 
  sub r2, r4 ;Zr^2 - Zi^2
  div r2, r5 ;(Zr^2 - Zi^2)/SCALE
  mov r0, r2
  getl r2 mandel.Cr
  add r0, r2
  setl mandel.Tr, r0
  mov r3, r0 ;new zr
  getl r0 mandel.temp
  mov r4, r0 ;new zi

  mul r0, r0 ;zi^2
  mov r2, r3
  mul r2, r2 ;zr^2
  add r0, r2
  getl r2 mandel.limit

  ;if
  jcmp r0, r2, .endif, .endif, $
  getl r0 mandel.bits
  orc r0, 1
  setl mandel.bits, r0
  jmp .doend
  .endif:

  addc r1, -1
  jcmpc r1, 0, $, $, .doloop
  .doend:
  
  ;restore x
  getl r1 mandel.x
  addc r1, 1 ;x++
  

  mov r0, r1
  andc r0, 7

  ;if2 - land of locals
  jcmpc r0, 0, .endif2, $, .endif2
  ;save x
  setl mandel.x, r1
  
  getl r1 mandel.bits
  movc r2, 0xff
  xor r1, r2
  getlp p2, mandel.output
  getl r0 mandel.index
  setb p2, r0, r1
  addc r0, 1 ;index++
  setl mandel.index, r0
  movc r0, 0
  setl mandel.bits, r0

  ;restore x
  getl r1 mandel.x
  .endif2:

  
  jmp .xloop
  .xend:
  ;restore y
  getl r2 mandel.y
  ;if3 - land of locals #2
  ;r3, r4, r0 free to use
  mov r3, r1
  andc r3, 7
  jcmpc r3, 0, $, .endif3, $
  getl r4, mandel.bits
  movc r3, 0xff
  xor r4, r3
  getlp p3, mandel.output
  getl r0 mandel.index
  setb p3, r0, r4
  addc r0, 1 ;index++
  setl mandel.index, r0
  movc r4, 0
  setl mandel.bits, r4  

  .endif3:
 
  addc r2, 1  ;y++
  jmp .yloop
  
  .yend:

  getlp p5, mandel.output
  out p5
ret