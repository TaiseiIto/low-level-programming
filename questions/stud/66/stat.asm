%define SYSCALL_EXIT 0x000000000000003c
global _start

section .text

_start:
	mov rax, SYSCALL_EXIT
	xor rdi, rdi
	syscall
