; int pow(int x, int y)
; =====================
; Calculates x^y, y>=0
; result in r0, r5 preserved
  
function pow
  int x
  int y

getl r1, pow.x ;r1: x
movc r0, 1 ;r0: 1
getl r2, pow.y ;r2: y
.loop:
    jcmpc r2, 0, .eloop, .eloop, $
    mul r0, r1
    addc r2, -1
    jmp .loop
.eloop:
ret

; int s_to_i(buffer s)
; ====================
; Returns s parsed as an int
; result in r0, r5 clobbered
  
function s_to_i
  ptr s
  int minus
  int ten
  int exp
  int acc
  ; legal numbers must match the form:
  ; [ws][sign][digits][ws]
  ; ws = TAB (9) or Space (32)
  ; sign = + (43) or - (45)
  ; up to 18 digits - this simplifies the code a lot at the expense of
  ; losing some huge numbers you can't even read
  movc r5, 0
  movc r3, 1
  setl s_to_i.minus, r3
  movc r3, 10
  setl s_to_i.ten, r3
  setl s_to_i.acc, r5
  getl r1, s_to_i.s
  movc r0, -1
.skipws:
  addc r0, 1
  getb r2, p1, r0
  jcmpc r2, 11, .error, .skipws, $ 
  jcmpc r2, 32, .error, .skipws, $
  ;ascii < 32 are all control chars except 11 and 0
  
  ;check for minus or plus
  movc r4, 0 ;digit count = 0
  jcmpc r2, 43, .error, .digit, $
  jcmpc r2, 45, .error, .neg, $
  addc r0, -1 ;reset this to hand over to .digit
  jmp .digit
  
.neg:
  movc r3, -1
  setl s_to_i.minus, r3
.digit:
  addc r0, 1
  getb r2, p1, r0
  jcmpc r2, 48, .isws, $, $
  jcmpc r2, 57, $, $, .error
  addc r4, 1 ;digit count += 1
  jcmpc r4, 19, .digit, .error, .error
  ;hitting a 19th digit is an error

.isws:
  jcmpc r4, 0, .error, .error, $
  ;ensure at least one digit (prevent [ws][sign][null])
.isws2:
  jcmpc r2, 0, .error, .convert, $
  jcmpc r2, 11, .error, .endws, $
  jcmpc r2, 32, .error, .endws, .error  
.endws:
  addc r0, 1
  addc r5, 1 ;keep count of how many chars after digits
  getb r2, p1, r0
  jcmpc r2, 0, .error, .convert, .isws2

.convert:
  ;r4 is how many digits we have
  ;r3 is a counter for 10's exponent
  ;r0 is pos in string
  ;r1 is the string
  ;r5 is num chars past the last digit we are
  sub r0, r5 ;r0 is now the pos of the last digit...
  mov r5, r0 ;move pos out of r0 for fn call
  movc r3, -1
.convertloop:
  addc r4, -1
  addc r3, 1
  getb r2, p1, r5
  addc r2, -48 ;ascii offset
  addc r5, -1
  ;calculation r2*(10^r3)
  setl s_to_i.exp, r3
  call pow, s_to_i.ten, 2
  mul r2, r0  
  ;accumulate
  getl r0, s_to_i.acc
  add r0, r2
  setl s_to_i.acc, r0
  jcmpc r4, 0, .error, .done, .convertloop
.error:

.done:
  getl r3, s_to_i.minus 
  mul r0, r3 ;change sign accordingly
ret  

; buffer strconcat(buffer a, buffer b)
; ====================================
; Returns concatenation of b onto the end of a
; result in r0, r5 clobbered
  
function strconcat
  ptr a
  ptr b

getl r1, strconcat.a ;r1: a
movc r0, 0 ;r0: length
.cloop1:
    getb r2, r1, r0
    jcmpc r2, 0, .cloop1e, .cloop1e, $
    addc r0, 1
    jmp .cloop1
.cloop1e:
mov r5, r0 ;store length of a for later
getl r1, strconcat.b ;r1: b
movc r2, 0 ;r2: index
.cloop2:
    getb r4, r1, r2
    jcmpc r4, 0, .cloop2e, .cloop2e, $
    addc r0, 1
    addc r2, 1
    jmp .cloop2
.cloop2e:
addc r0, 1 ;add \0
newa r4, r0
;recap:
;r0: length of new array
;r1: b
;r2: length of b
;r3: nothing
;r4: output
;r5: length of a
;rearrange for ease of use
mov r0, r4           ;r0: output
mov r1, r5           ;r1: len(a)
                     ;r2: len(b)
getl r3, strconcat.a ;r3: a
movc r4, 0           ;r4: index into a
.mloop1:
    jcmpc r1, 0, .mloop1e, .mloop1e, $
    getb r5, r3, r4
    setb r0, r4, r5
    addc r1, -1
    addc r4, 1
    jmp .mloop1
.mloop1e:
getl r3, strconcat.b
mov r1, r4
movc r4, 0
.mloop2:
    jcmpc r2, 0, .mloop2e, .mloop2e, $
    getb r5, r3, r4
    setb r0, r1, r5
    addc r4, 1
    addc r1, 1
    addc r2, -1
    jmp .mloop2
.mloop2e:
movc r5, 0
setb r0, r1, r5
ret

; buffer bufferclone(buffer a, int length)
; ====================================
; Returns a new buffer with a copy of the contents of a
; result in r0, r5 preserved
function bufferclone
  ptr a
  int length

  getlp r4, bufferclone.a
  getl r1, bufferclone.length
  newa r0, r1
  .loop:
  addc r1, -1
  jcmpc r1, 0, .end, $, $
  getb r2, r4, r1
  setb r0, r1, r2
  jmp .loop
  
  .end:
ret

; buffer buffercopy(buffer a, buffer b, int length)
; ================================================
; copies a into b and returns b in r0
function buffercopy
  ptr a
  ptr b
  int length
  getl p1, buffercopy.a
  getl p0, buffercopy.b
  getl r2, buffercopy.length

  .loop:
  addc r2, -1
  jcmpc r2, 0, .end, $, $
  getb r3, p1, r2
  setb p0, r2, r3
  jmp .loop

  .end:
ret