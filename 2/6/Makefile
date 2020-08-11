all: strlen strlen_bug1

strlen: strlen.o
	ld $^ -o $@

strlen_bug1: strlen_bug1.o
	ld $^ -o $@

%.o: %.asm
	nasm $^ -f elf64 -o $@

