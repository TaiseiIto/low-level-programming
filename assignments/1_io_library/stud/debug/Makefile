all:debugee

clean:
	rm debugee debugee.o

debugee:debugee.o
	ld $^ -o $@

debugee.o:debugee.asm
	nasm -f elf64 -g $^ -o $@

