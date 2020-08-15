all:fibonacci

fibonacci:fibonacci.o
fibonacci.o:fibonacci.asm

%:%.o
	ld $^ -o $@

%.o:%.asm
	nasm $^ -f elf64 -g -o $@

