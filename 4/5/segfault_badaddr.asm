section .data
correct: dq -1
section .text

global _start
_start:
	mov [0x400000 - 1], rax
	mov rax, 60
	xor rdi, rdi
	syscall

