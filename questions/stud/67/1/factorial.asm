%define SYSCALL_EXIT 0x000000000000003c

global _start

section .text

_start:				;int main(void)
				;{
	mov rax, SYSCALL_EXIT	;
	xor rdi, rdi		;
	syscall			;	exit(rdi:0);
				;}
	
