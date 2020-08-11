all:print_rax

print_rax:print_rax.o
	ld $^ -o $@

print_rax.o:print_rax.asm
	nasm -f elf64 $^ -o $@

