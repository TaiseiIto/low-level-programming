all:mappings_loop.exe segfault_badaddr.exe

clean:
	rm *.exe *.o

mappings_loop.exe:mappings_loop.o
mappings_loop.o:mappings_loop.asm
segfault_badaddr.exe:segfault_badaddr.o
segfault_badaddr.o:segfault_badaddr.asm

%.exe:%.o
	ld $^ -o $@

%.o:%.asm
	nasm $^ -f elf64 -o $@

