global _start

section .data

message: db 'Hello, World!', 0x0a	;char *message = "Hello, World!\n";

section .text

_start:					;int main(void)
					;{
	mov rax, 1			;	rax = 1:(write system call ID);
	mov rdi, 1			;	rdi = 1:stdout;
	mov rsi, message		;	rsi = message:"Hello, World!\n";
	mov rdx, 14			;	rdx = 14:strlen(rsi:message:"Hello, World!\n");
	syscall				;	write(rdi:1:stdout, rsi:message:"Hello, World!\n", rdx:14:strlen(rsi:message:"Hello, World!\n"));
	mov rax, 60			;	rax = 60:(exit system call ID);
	mov rdi, 0			;	rdi = 0:(return value);
	syscall				;	return rdi:0;
					;}

