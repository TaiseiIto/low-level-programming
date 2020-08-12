all:stat stat_struct

clean:
	rm stat stat.o stat_struct

stat:stat.o

stat_struct:stat_struct.c
	gcc $^ -o $@

stat.o:stat.asm

%:%.o
	ld $^ -o $@

%.o:%.asm
	nasm $^ -f elf64 -g -o $@

