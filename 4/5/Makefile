all:mapping_loop

mapping_loop:mapping_loop.o
	ld $^ -o $@

mapping_loop.o:mappings_loop.asm
	nasm $^ -f elf64 -o $@

