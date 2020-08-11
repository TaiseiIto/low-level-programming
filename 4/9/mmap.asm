%define CHAR_NEWLINE 0x0a
%define CHAR_NULL 0x00
%define MAP_PRIVATE 0x0000000000000002
%define PROT_READ 0x0000000000000001
%define STDOUT 0x0000000000000001
%define STDERR 0x0000000000000002
%define SYSCALL_CLOSE 0x06
%define SYSCALL_EXIT 0x3c
%define SYSCALL_MMAP 0x09
%define SYSCALL_MUMAP 0x0b
%define SYSCALL_OPEN 0x02
%define SYSCALL_WRITE 0x01

global _start

section .data

file_name: db 'test.txt', CHAR_NULL	;char * const file_name = "test.txt";
close_failure_message: db 'CLOSE FAILURE!', CHAR_NEWLINE, CHAR_NULL;char * const close_failure_message = "CLOSE FAILURE!\n";
mmap_failure_message: db 'MMAP_FAILURE!', CHAR_NEWLINE, CHAR_NULL;char * const mmap_failure_message = "MMAP FAILURE!\n";
mumap_failure_message: db 'MUMAP_FAILURE!', CHAR_NEWLINE, CHAR_NULL;char * const mumap_failure_message = "MUMAP FAILURE!\n";
no_file_name_message: db 'NO FILE NAME!', CHAR_NEWLINE, CHAR_NULL;char * const no_file_name_message = "NO FILE NAME!\n";
open_failure_message: db 'OPEN FAILURE!', CHAR_NEWLINE, CHAR_NULL;char * const open_failure_message = "OPEN FAILURE!\n";
write_failure_message: db 'WRITE_FAILURE!', CHAR_NEWLINE, CHAR_NULL;char * const write_failure_message = "WRITE FAILURE!\n";

section .text

error_message:			;void error_message(char *rdi:message)
				;{
	push rdi		;	*(rsp -= 8) = rdi:message;
	call string_length	;
	mov rdx, rax		;	rdx = rax:string_length(open_failure_message);
	mov rax, SYSCALL_WRITE	;	write(rdi:stdout, rsi:open_failure_message, rdx:string_length(open_failure_message));
	mov rdi, STDERR		;
	pop rsi			;	rsi = *rsp:message; rsp += 8;
	syscall			;
	mov rax, SYSCALL_EXIT	;	exit(1);
	mov rdi, 1		;
	syscall			;
				;}

print_string:			;unsigned long:(num of written bytes) print_string(char *rdi:string)//print string to stdout
				;{
	push rdi		;	*(rsp -= 8) = rdi:string;
	call string_length	;	rax = string_length(rdi:string);
	mov rdx, rax		;	rdx = rax:string_length(string);
	mov rax, SYSCALL_WRITE	;	rax = syscall_write;
	mov rdi, STDOUT		;	rdi = stdout;
	pop rsi			;	rsi = (*rsp):string; rsp += 8;
	syscall			;	rax = write(rdi:stdout, rsi:string, rdx:string_length(string)):(num of written bytes);
	mov rdx, -1		;	if(rax == -1)goto .write_failure;
	cmp rax, rdx		;
	je .write_failure	;
	ret			;	return rax:(num of written bytes);
.write_failure:			;.write_failure:
	mov rdi, write_failure_message;	error_message(write_failure_message);
	call error_message	;
				;}

_start:				;int main(void)
				;{
	cmp qword[rsp], 1	;	if(argc == 1)goto .no_file_name;
	je .no_file_name	;
	mov rax, SYSCALL_OPEN	;	rax = open(rdi:file_name, rsi:0/*Read Only*/, rdx:0/*permission mode when the file is created*/):(success:(file descriptor), failure:-1);
	mov rdi, file_name	;
	xor rsi, rsi		;//Read Only
	xor rdx, rdx		;//permission mode when the file is created
	syscall			;
	mov rdx, -1		;	if(rax == -1)goto .open_failure;
	cmp rax, rdx		;
	je .open_failure	;
	push rax		;	*(rsp -= 8) = (file descriptor);
	mov rax, SYSCALL_MMAP	;	rax = mmap(rdi:(destination address), rsi:(num of mapping bytes), rdx:(protection flags), r10:(flags), r8:(file descriptor), r9:(offset in the file)):(success:(destination address), failure:-1);//copy file content to memory
	xor rdi, rdi		;		//entrust destination address determination to OS
	mov rsi, 0x1000		;		//1KB
	push rsi		;	*(rsp -= 8) = rsi:(mapped size);
	mov rdx, PROT_READ	;		//read only
	mov r10, MAP_PRIVATE	;		//unshared among processes
	mov r8, qword[rsp + 8]	;		//opened file descriptor
	xor r9, r9		;		//map the file from first byte
	syscall			;
	mov rdx, -1		;	if(rax == -1)goto .mmap_failure;
	cmp rax, rdx		;
	je .mmap_failure	;
	push rax		;	*(rsp -= 8) = (mapped address);
	mov rdi, rax		;	rdi = rax:(mapped address);
	call print_string	;	print_string(rdi:(mapped address));
	mov rax, SYSCALL_MUMAP	;	rax = mumap(rdi:(mapped address), rsi:(mapped size)):(success:0, failure:-1);
	pop rdi			;	rdi = *rsp:(mapped address); rsp += 8;
	pop rsi			;	rsi = *rsp:(mapped size); rsp += 8;
	syscall			;
	test rax, rax		;	if(rax != 0)goto .mumap_failure;
	jnz .mumap_failure	;
	pop rdi			;	rdi = *rsp:(file descriptor); rsp += 8;
	mov rax, SYSCALL_CLOSE	;	rax = close(rdi:(file descriptor)):(success:0, failure:-1);
	syscall			;
	mov rdx, -1		;	if(rax != 0)goto .close_failure;
	cmp rax, rdx
	je .close_failure	;
	mov rax, SYSCALL_EXIT	;	exit(0);
	xor rdi, rdi		;
	syscall			;
.close_failure:			;.close_failure:
	mov rdi, close_failure_message;	error_message(close_failure_message);
	call error_message	;
.mmap_failure:			;.mmap_failure:
	mov rdi, mmap_failure_message;	error_message(mmap_failure_message);
	call error_message	;
.mumap_failure:			;.mmap_failure:
	mov rdi, mumap_failure_message;	error_message(mumap_failure_message);
	call error_message	;
.no_file_name:			;.no_file_name:
	mov rdi, no_file_name_message; error_message(no_file_name_message);
	call error_message	;
.open_failure:			;.open_failure:
	mov rdi, open_failure_message;	error_message(open_failure_message);
	call error_message	;
				;}

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

