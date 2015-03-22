movc r1, 1

outloop:
     addc r1, 1
     mov r2, r1
         loop:
         subc r2, 1

         jcmpc r2, 1, prime, prime, cont ;if r2 1, prime. else keep going
         cont:
         mov r3, r1
         div r1, r2
         mov r1, r3
         jcmpc r0, 0, outloop, outloop, loop
    
        prime:
            mov r5, r1
            jmp outloop