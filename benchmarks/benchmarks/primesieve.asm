;Finds prime numbers using the Sieve of Eratosthenes
function primesieve
  int n
  ptr list
  int x
  
  movc r1, 1000000 ;find primes up to this number
  ; for 1 000 000, should take around three minutes
  setl .n, r1
  
  newp r0, LinkedList ;r0: linked list
  movp r4, r0 ;save linked list so we can rewind
  
  ;Fill linked list with n elements
  movc r2, 2
  .cloop:
  setmp r0, LinkedList.value, r2
  newp r3, LinkedList
  setmp r0, LinkedList.next, r3
  movp r0, r3
  addc r2, 1
  jcmp r2, r1, .cloop, .cloop, .cend
  .cend:
  null r2
  setmp r0, LinkedList.next, r2
  movp r0, r4 ;rewind linked list
  
  .loop:
  jnullp r0, $, .end
  getm r1, r0, LinkedList.value
  getmp r0, r0, LinkedList.next
  jnullp r0, $, .end
  setl primesieve.list, r0
  setl primesieve.x, r1
  call removeMultiples, primesieve.list, 2
  jmp .loop
  .end:
  mov r1, r4 ;rewind list again
  
  .ploop:
  jnullp r1, $, .pend
  getm r0, r1, LinkedList.value
  print r0
  getmp r1, r1, LinkedList.next
  jmp .ploop
  .pend:
ret
  
object LinkedList
  int value
  ptr next
  
function removeMultiples
  ptr list
  int n
  ptr sl
  int sn
  
  getl r1, .list
  getl r2, .n
  mov r3, r2
  .loop:
  jnullp r1, $, .end
  getmp r3, r1, LinkedList.next
  jnullp r3, $, .end
  getm r3, r3, LinkedList.value
  div r3, r2
  jcmpc r0, 0, .remove, .remove, .continue
  .remove:
  getmp r3, r1, LinkedList.next
  getmp r3, r3, LinkedList.next
  setmp r1, LinkedList.next, r3
  .continue:
  getmp r1, r1, LinkedList.next
  jmp .loop    
  .end:
  getlp r0, .list
ret
  
%include ../stdlib.asm