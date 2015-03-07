all: clean vm
vm: utility.o vm.o
	gcc utility.o vm.o -o vm
	chmod u+x vm

run: all
	./vm
debug:
	gdb --directory . vm
utility.o: utility.c
	gcc -g -c utility.c -o utility.o

vm.o: vm.asm utility.h.asm
	nasm -g -f elf64 vm.asm -o vm.o

clean:
	rm -f *.o vm
