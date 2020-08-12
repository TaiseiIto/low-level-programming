%define CHAR_NEWLINE 0x0a
%define CHAR_NULL 0x00
%define MAP_PRIVATE 0x0000000000000002
%define PROT_READ 0x0000000000000001
%define STDOUT 0x0000000000000001
%define STDERR 0x0000000000000002
%define SYSCALL_CLOSE 0x0000000000000003
%define SYSCALL_EXIT 0x000000000000003c
%define SYSCALL_FSTAT 0x0000000000000005
%define SYSCALL_MMAP 0x0000000000000009
%define SYSCALL_MUMAP 0x000000000000000b
%define SYSCALL_OPEN 0x0000000000000002
%define SYSCALL_WRITE 0x0000000000000001

%define MMAP_UNIT 0x1000

global _start

section .data

stat:
			dq 0x0000000000000000
.st_dev:		dq 0x0000000000000000
.st_ino:		dq 0x0000000000000000
.st_nlink:		dq 0x0000000000000000
.st_mode:		dw 0x00000000
.st_uid:		dw 0x00000000
.st_gid:		dw 0x00000000
.__pad0:		dw 0x00000000
.st_rev:		dq 0x0000000000000000
.st_size:		dq 0x0000000000000000
.st_blksize:		dq 0x0000000000000000
.st_blocks:		dq 0x0000000000000000
.st_atim.tv_sec:	dq 0x0000000000000000
.st_atim.tv_nsec:	dq 0x0000000000000000
.st_mtim.tv_sec:	dq 0x0000000000000000
.st_mtim.tv_nsec:	dq 0x0000000000000000
.st_ctim.tv_sec:	dq 0x0000000000000000
.st_ctim.tv_nsec:	dq 0x0000000000000000
.__glibc_reserved_0:	dq 0x0000000000000000
.__glibc_reserved_1:	dq 0x0000000000000000
.__glibc_reserved_2:	dq 0x0000000000000000

close_error: db 'CLOSE ERROR!', CHAR_NEWLINE, CHAR_NULL;char * const close_error = "CLOSE error!\n";
fstat_error: db 'FSTAT ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *fstat_error = "FSTAT ERROR!\n";
mmap_error: db 'MMAP ERROR!', CHAR_NEWLINE, CHAR_NULL;char * const mmap_error = "MMAP error!\n";
mumap_error: db 'MUMAP ERROR!', CHAR_NEWLINE, CHAR_NULL;char * const mumap_error = "MUMAP error!\n";
no_file_name_message: db 'NO FILE NAME!', CHAR_NEWLINE, CHAR_NULL;char * const no_file_name_message = "NO FILE NAME!\n";
open_error: db 'OPEN ERROR!', CHAR_NEWLINE, CHAR_NULL;char * const open_error = "OPEN error!\n";
write_error: db 'WRITE ERROR!', CHAR_NEWLINE, CHAR_NULL;char * const write_error = "WRITE error!\n";

section .text

error:			;void error(char *rdi:message)
				;{
	push rdi		;	*(rsp -= 8) = rdi:message;
	mov rsi, -1		;	rsi:(max length) = -1;
	call string_length	;
	mov rdx, rax		;	rdx = rax:string_length(rdi:message, rsi:(max length));
	mov rax, SYSCALL_WRITE	;	write(rdi:stdout, rsi:open_error, rdx:string_length(open_error));
	mov rdi, STDERR		;
	pop rsi			;	rsi = *rsp:message; rsp += 8;
	syscall			;
	mov rax, SYSCALL_EXIT	;	exit(1);
	mov rdi, 1		;
	syscall			;
				;}

_start:				;int main(void)
				;{
	cmp qword[rsp], 1	;	if(argc == 1)goto .no_file_name;//argc == qword[rsp]
	je .no_file_name	;
.open:				;.open:
	mov rax, SYSCALL_OPEN	;	rax = open(rdi:file_name, rsi:0/*Read Only*/, rdx:0/*permission mode when the file is created*/):(success:(file descriptor), error:-1);
	mov rdi, qword[rsp + 16];		//argv[n] == qword[rsp + 8 + 8 * n];
	xor rsi, rsi		;		//Read Only
	xor rdx, rdx		;		//permission mode when the file is created
	syscall			;
	cmp rax, 0		;	if(rax < 0)goto .open_error
	jl .open_error		;
	push rax		;	*(rsp -= 8) = (file descriptor);
.fstat:				;.fstat:
	mov rax, SYSCALL_FSTAT	;
	mov rdi, qword[rsp]	;
	mov rsi, stat		;
	syscall			;	rax = fstat(rdi/*file descriptor*/, rsi/*stat struct addr*/)/*success:0, error:negative*/;
	test rax, rax		;
	jnz .fstat_error	;	if(rax != 0)goto .fstat_error;
	xor r9, r9		;	(r9:(mmap offset) ^= r9):(r9 =0);
.mmap:				;.mmap:
	cmp qword[stat.st_size], r9;	if(stat->st_size <= r9)goto .close;
	jbe .close		;
	mov rax, SYSCALL_MMAP	;	rax = mmap(rdi:(mapped address), rsi:length, rdx:(protection flags), r10:(flags), r8:(file descriptor), r9:(offset)):(success:(mapped address), error:-1);
	xor rdi, rdi		;	(rdi:(mapped address) ^= rdi):(rdi = 0);//entrust addressing to OS
	mov rsi, MMAP_UNIT	;		//length
	mov rdx, PROT_READ	;		//read only
	mov r10, MAP_PRIVATE	;		//unshared among processes
	mov r8, qword[rsp]	;		//file descriptor
	syscall			;
	cmp rax, 0		;	if(rax:(mapped address) < 0)goto .mmap_error;
	jl .mmap_error		;
	push rax		;	*(rsp -= 8) = rax:(mapped address);
	add r9, MMAP_UNIT	;	r9:(mmap offset) += MMAP_UNIT;
	push r9			;	*(rsp -= 8) = r9:(mmap offset);
.write:				;.write:
	mov rdi, qword[rsp + 8]	;	rdi = rsp[1]:(mapped address);
	mov rsi, MMAP_UNIT	;	rsi = MMAP_UNIT;
	call string_length	;	rax = string_length(rdi:(mapped address), rsi:MMAP_UNIT);
	mov rdx, rax		;	rdx = rax:(mapped string length);
	mov rax, SYSCALL_WRITE	;	rax = SYSCALL_WRITE;
	mov rsi, qword[rsp + 8]	;	rsi = rsp[1]:(mapped address);
	mov rdi, STDOUT		;	rdi = STDOUT;
	syscall			;	rax = write(rdi:stdout, rsi:(mapped address), rdx:length);
.mumap:				;.mumap:
	pop r9			;	r9 = *rsp:(mmap offset); rsp += 8;
	mov rax, SYSCALL_MUMAP	;	rax = mumap(rdi:(mapped address), rsi:length):(success:0, error:-1);
	pop rdi			;	rdi = *rsp:(mapped address); rsp += 8;
	mov rsi, MMAP_UNIT	;		//length
	syscall			;
	test rax, rax		;	if(rax != 0)goto .mumap_error;
	jnz .mumap_error	;
	jmp .mmap		;	goto .mmap;
.close:				;.close:
	pop rdi			;	rdi = *rsp:(file descriptor); rsp += 8;
	mov rax, SYSCALL_CLOSE	;	rax = close(rdi:(file descriptor)):(success:0, error:-1);
	syscall			;
	test rax, rax		;	if(rax != 0)goto .close_error;
	jnz .close_error	;
.exit:				;.exit:
	mov rax, SYSCALL_EXIT	;	exit(0);
	xor rdi, rdi		;
	syscall			;
.close_error:			;.close_error:
	mov rdi, close_error;	error(close_error);
	call error	;
.fstat_error:				;.close_error:
	mov rdi, fstat_error	;
	call error			;	error(rdi:fstat_error);
.mmap_error:			;.mmap_error:
	mov rdi, mmap_error;	error(mmap_error);
	call error	;
.mumap_error:			;.mmap_error:
	mov rdi, mumap_error;	error(mumap_error);
	call error	;
.no_file_name:			;.no_file_name:
	mov rdi, no_file_name_message; error(no_file_name_message);
	call error	;
.open_error:			;.open_error:
	mov rdi, open_error;	error(open_error);
	call error	;
				;}

string_length:			;unsigned long string_length(char *rdi:string, unsigned long rsi:(max length))
				;{
	xor rax, rax		;	(rax ^= rax):(rax = 0);
.check_next_8_bytes:		;.check_next_8_bytes:
	mov rdx, qword[rdi]	;	rdx = *(long *)rdi;//8 characters
	xor rcx, rcx		;	(rcx:(num of checked bytes) ^= rcx):(rcx = 0);
.check_next_byte:		;.check_next_byte:
	cmp dl, CHAR_NULL	;	if(dl == '\0')goto .end;
	je .end			;
	inc rax			;	rax++;
	cmp rax, rsi		;	if(rax == rsi:(max length))goto .end;
	je .end			;
	inc rcx			;	rcx++;
	shr rdx, 8		;	rdx >>= 8;
	cmp rcx, 8		;	if(rcx:(num of checked bytes) < 8)goto .check_next_byte;
	jb .check_next_byte	;
	add rdi, 8		;	rdi:(checked address) += 8;
	jmp .check_next_8_bytes	;	goto .check_next_8_bytes;
.end:				;.end:
	ret			;	return rax;
				;}

