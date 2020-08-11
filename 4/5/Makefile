all:mapping_loop.exe segfault_badaddr.exe

clean:
	rm *.exe *.o

%.exe:%.o
	ld $^ -o $@

%.o:%.asm
	nasm $^ -f elf64 -o $@

