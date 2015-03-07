GCCARGS = -g -std=c99
all: clean vm
vm: utility.o vm.o
	gcc utility.o vm.o -o vm -nostartfiles
	chmod u+x vm

run: all
	./vm
debug:
	gdb --directory . vm -tui
utility.o: utility.c
	gcc $(GCCARGS) -c utility.c -o utility.o

vm.o: vm.asm utility.h.asm
	nasm -g -f elf64 vm.asm -o vm.o

clean:
	rm -f *.o vm
