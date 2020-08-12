%define CHAR_NEWLINE 0x0a
%define CHAR_NULL 0x00
%define STDERR 0x0000000000000002
%define SYSCALL_EXIT 0x000000000000003c
%define SYSCALL_WRITE 0x0000000000000001

global _start

section .data

no_file_name_message: db 'NO FILE NAME!', CHAR_NEWLINE, CHAR_NULL	;char *no_file_name_message = "NO FILE NAME!\n";

section .text

error:					;void error(char *rdi:message)
					;{
	push rdi			;	//stack rdi/*message*/
	mov rsi, -1			;
	call string_length		;	rax = string_length(rdi:message, rsi:-1/*max length*/);
	mov rdx, rax			;	rdx = rax/*message length*/;
	mov rax, SYSCALL_WRITE		;
	mov rdi, STDERR			;
	pop rsi				;	rsi = message;//stack
	syscall				;	rax = write(rdi:stderr, rsi:message, rdx/*message length*/)/*num of written bytes*/;
	mov rax, SYSCALL_EXIT		;
	mov rdi, 1			;
	syscall				;	exit(rdi:1);
					;}

_start:					;int main(int argc, char **argv)
					;{
	cmp qword[rsp], 1		;
	je .no_file_name		;	if(argc == 1)goto .no_file_name;
	mov rax, SYSCALL_EXIT		;
	xor rdi, rdi			;
	syscall				;	exit(rdi:0);
.no_file_name:				;.no_file_name:
	mov rdi, no_file_name_message	;
	call error			;	error(rdi:no_file_name_message);
					;}

string_length:				;unsigned long string_length(char *rdi:string, unsigned long rsi/*max length*/)
					;{
	xor rax, rax			;	unsigned long rax/*length*/ = 0;
.check_8_bytes:				;.check_8_bytes:
	mov rdx, qword[rdi]		;	long rdx/*current 8 bytes*/ = *(long *)rdi;
	xor rcx, rcx			;	rcx/*num of checked bytes of rdx*/ = 0;
.check_1_byte:				;.check_1_byte:
	cmp dl, CHAR_NULL		;
	je .end				;	if(dl == '\0')goto .end;
	inc rax				;	rax/*length*/++;
	cmp rax, rsi			;
	je .end				;	if(rax/*length*/ == rsi/*max length*/)goto .end;
	shr rdx, 8			;	rdx >>= 8;
	inc rcx				;	rcx/*num of checked bytes of rdx*/++;
	cmp rcx, 8			;
	jb .check_1_byte		;	if(rcx < 8)goto .check_1_byte;
	add rdi, 8			;	rdi/*pointer of currect 8 bytes*/++;//pass 8 bytes
	jmp .check_8_bytes		;	goto .check_8_bytes;
.end:					;.end:
	ret				;	return rax;
					;}
