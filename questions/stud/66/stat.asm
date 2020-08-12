%define CHAR_NEWLINE 0x0a
%define CHAR_NULL 0x00
%define SYSCALL_EXIT 0x000000000000003c

global _start

section .data

no_file_name_message: db 'NO FILE NAME!', CHAR_NEWLINE, CHAR_NULL	;char *no_file_name_message = "NO FILE NAME!\n";

section .text

error:					;void error(char *rdi:message)
					;{
	mov rax, SYSCALL_EXIT		;
	mov rdi, 1			;
	syscall				;	exit(1);
					;}

_start:					;int main(int argc, char **argv)
					;{
	cmp qword[rsp], 1		;
	je .no_file_name		;	if(argc == 1)goto .no_file_name;
	mov rax, SYSCALL_EXIT		;
	xor rdi, rdi			;
	syscall				;	exit(0);
.no_file_name:				;.no_file_name:
	mov rdi, no_file_name_message	;
	call error			;	error(rdi:no_file_name_message);
					;}

