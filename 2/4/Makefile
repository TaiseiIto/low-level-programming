all:print_call

print_call:print_call.o
	ld $^ -o $@

print_call.o:print_call.asm
	nasm -f elf64 $^ -o $@

