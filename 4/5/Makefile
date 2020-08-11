all:main

main:main.o
	ld $^ -o $@

main.o:mappings_loop.asm
	nasm $^ -f elf64 -o $@

