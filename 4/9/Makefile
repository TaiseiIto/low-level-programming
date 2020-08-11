all:mmap

clean:
	rm mmap mmap.o

mmap:mmap.o
	ld $^ -o $@

mmap.o:mmap.asm
	nasm $^ -f elf64 -g -o $@

