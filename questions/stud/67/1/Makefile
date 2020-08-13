all:factorial

factorial:factorial.o
factorial.o:factorial.asm

%:%.o
	ld $^ -o $@

%.o:%.asm
	nasm $^ -f elf64 -g -o $@

