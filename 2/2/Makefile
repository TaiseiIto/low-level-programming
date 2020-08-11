all:hello

hello:hello.o
	ld $^ -o $@

hello.o:hello.asm
	nasm -f elf64 $^ -o $@

