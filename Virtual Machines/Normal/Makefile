GCCARGS = -g -std=c99

all: clean vm
vm: utility.o vm.o
	gcc utility.o vm.o -o vm
	chmod u+x vm

run: all
	./vm

debug: all
	gdb --directory . vm -tui --command=gdbinit

utility.o: ../Common/utility.c
	gcc $(GCCARGS) -c ../Common/utility.c -o utility.o

vectors.asm:
	./generate.rb > vectors.asm

vm.o: vm.asm ../Common/utility.h.asm vectors.asm code.asm
	yasm -g dwarf2 -f elf64 vm.asm -o vm.o

clean:
	rm -f *.o vm
	rm -f vectors.asm
