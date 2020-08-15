all:digitsum

digitsum:digitsum.o
digitsum.o:digitsum.asm

%:%.o
	ld $^ -o $@

%.o:%.asm
	nasm $^ -f elf64 -g -o $@

