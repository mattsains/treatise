GCCARGS = -g -std=c99
all: clean vm
vm: utility.o vm.o
	gcc utility.o vm.o -o vm
	chmod u+x vm

run: all
	./vm
debug: all
	gdb --directory . vm -tui

utility.o: ../Common/utility.c
	gcc $(GCCARGS) -c ../Common/utility.c -o utility.o

dispatch_numbers.asm:
	./generate.rb > dispatch_numbers.asm

vm.o: vm.asm ../Common/utility.h.asm dispatch_numbers.asm
	nasm -g -f elf64 vm.asm -o vm.o

clean:
	rm -f *.o vm