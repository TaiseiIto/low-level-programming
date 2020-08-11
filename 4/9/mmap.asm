%define CHAR_NULL 0x00
%define STDOUT 0x0000000000000001
%define SYSCALL_CLOSE 0x06
%define SYSCALL_EXIT 0x3c
%define SYSCALL_OPEN 0x02
%define SYSCALL_WRITE 0x01

global _start

section .data

open_failure_message: db 'cannot open '	;char * const open_failure_message = "cannot open test.txt";
file_name: db 'test.txt', CHAR_NULL	;char * const file_name = open_failure_message + 12;

section .text

string_length:			;unsigned long string_length(char *rdi:string)
				;{
	xor rax, rax		;	(rax ^= rax):(rax = 0);
.check_next_8_bytes:		;.check_next_8_bytes:
	mov rdx, qword[rdi]	;	rdx = *(long *)rdi;//8 characters
	xor rcx, rcx		;	(rcx:(num of checked bytes) ^= rcx):(rcx = 0);
.check_next_byte:		;.check_next_byte:
	cmp dl, CHAR_NULL	;	if(dl == '\0')goto .end;
	je .end
	inc rax			;	rax++;
	inc rcx			;	rcx++;
	shr rdx, 8		;	rdx >>= 8;
	cmp rcx, 8		;	if(rcx:(num of checked bytes) < 8)goto .check_next_byte;
	jb .check_next_byte;
	add rdi, 8		;	rdi:(checked address) += 8;
	jmp .check_next_8_bytes	;	goto .check_next_8_bytes;
.end:				;.end:
	ret			;	return rax;
				;}

_start:				;int main(void)
				;{
	mov rax, SYSCALL_OPEN	;	rax:(file descriptor) = open(rdi:file_name, rsi:0/*Read Only*/, rdx:0/*permission mode when the file is created*/);
	mov rdi, file_name	;
	xor rsi, rsi		;//Read Only
	xor rdx, rdx		;//permission mode when the file is created
	syscall			;
	mov rdx, -1		;	if(file == NULL)goto .open_failure;
	cmp rax, rdx		;
	je .open_failure	;
	mov rdi, rax		;	rdi = rax:(file descriptor);
	mov rax, SYSCALL_CLOSE	;	close(rdi:(file descriptor));
	syscall			;
	mov rax, SYSCALL_EXIT	;	exit(0);
	xor rdi, rdi		;
	syscall			;
.open_failure:			;.open_failure:
	mov rdi, open_failure_message;	rax = string_length(open_failure_message);
	call string_length	;
	mov rdx, rax		;	rdx = rax:string_length(open_failure_message);
	mov rax, SYSCALL_WRITE	;	write(rdi:stdout, rsi:open_failure_message, rdx:string_length(open_failure_message));
	mov rdi, STDOUT		;
	mov rsi, open_failure_message;
	syscall			;
	mov rax, SYSCALL_EXIT	;	exit(1);
	mov rdi, 1		;
	syscall			;
				;}
