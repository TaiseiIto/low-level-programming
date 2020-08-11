all:endianness

endianness:endianness.o
	ld $^ -o $@

endianness.o:endianness.asm
	nasm -f elf64 $^ -o $@

