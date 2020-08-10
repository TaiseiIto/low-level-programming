all:debugee

debugee:debugee.o
	ld $^ -o $@

debugee.o:debugee.asm
	nasm -f elf64 $^ -o $@

