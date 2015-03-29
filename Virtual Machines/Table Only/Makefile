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

codetable.asm: generate.rb
	./generate.rb > codetable.asm

vm.o: vm.asm ../Common/utility.h.asm codetable.asm
	yasm -g dwarf2 -f elf64 vm.asm -o vm.o

clean:
	rm -f *.o vm codetable.asm
