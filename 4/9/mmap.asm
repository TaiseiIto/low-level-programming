%define SYSCALL_EXIT 60
global _start

section .text

_start:				;int main(void)
				;{
	mov rax, SYSCALL_EXIT	;	exit(0);
	xor rdi, rdi		;
	syscall			;
				;}
