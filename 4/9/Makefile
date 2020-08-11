all:mmap

mmap:mmap.o
	ld $^ -o $@

mmap.o:mmap.asm
	nasm $^ -f elf64 -o $@

