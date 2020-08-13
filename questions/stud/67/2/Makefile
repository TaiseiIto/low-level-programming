all:prime

prime:prime.o
prime.o:prime.asm

%:%.o
	ld $^ -o $@

%.o:%.asm
	nasm $^ -f elf64 -g -o $@

