all:isfibonacci

isfibonacci:isfibonacci.o
isfibonacci.o:isfibonacci.asm

%:%.o
	ld $^ -o $@

%.o:%.asm
	nasm $^ -f elf64 -g -o $@

