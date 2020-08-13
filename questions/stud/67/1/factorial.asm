%define CHAR_NEWLINE 0x0a
%define CHAR_NULL 0x00
%define STDERR 0x0000000000000002
%define STDOUT 0x0000000000000001
%define SYSCALL_CLOSE 0x0000000000000003
%define SYSCALL_EXIT 0x000000000000003c
%define SYSCALL_FSTAT 0x0000000000000005
%define SYSCALL_MMAP 0x0000000000000009
%define SYSCALL_MUMAP 0x0000000000000011
%define SYSCALL_OPEN 0x0000000000000002
%define SYSCALL_WRITE 0x0000000000000001

global _start

section .data

error_message:
.close: db 'CLOSE ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *error_message.close = "CLOSE ERROR!\n";
.fstat: db 'FSTAT ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *error_message.fstat = "FSTAT ERROR!\n";
.open: db 'OPEN ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *error_message.open = "OPEN ERROR!\n";
input_file_name: db 'input.txt', CHAR_NULL ;char *input_file_name = "input.txt";

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

section .text

error:				;void error(char *rdi:error_message)
				;{
	push rdi		;	//rsp error_message
	mov rsi, -1		;
	call string_length	;	rax = string_length(rdi:error_message, rsi:-1/*max length*/);
	mov rdx, rax		;
	mov rax, SYSCALL_WRITE	;
	mov rdi, STDERR		;
	pop rsi			;	rsi = (error_message); //rsp
	syscall			;	rax = write(rdi:stderr, rsi:error_message, rdx:strlen(error_message))/*num of written bytes*/;
	mov rax, SYSCALL_EXIT	;
	mov rdi, 1		;	//return value
	syscall			;	exit(rdi:1);
				;}

_start:				;int main(void)
				;{
.open:				;.open:
	mov rax, SYSCALL_OPEN	;
	mov rdi, input_file_name;	//"input.txt"
	xor rsi, rsi		;	//read only
	xor rdx, rdx		;	//file mode when the file is created novelly
	syscall			;	rax = open(rdi:input_file_name:"input.txt"/*file name*/, rsi:0:O_RDONLY/*read only*/, rdx:0/*possessor, possessor group and the other users can't read, write and execute the file created novely*/)/*success:file descriptor, error:negative*/;
	cmp rax, 0		;
	jl .open_error		;	if(rax < 0)goto .open_error;
	push rax		;	//rsp (file descriptor) argc argv[0]
.fstat:				;.fstat:
	mov rax, SYSCALL_FSTAT	;
	mov rdi, qword[rsp]	;	//file descriptor
	mov rsi, stat		;	//stat address
	syscall			;	rax = fstat(rdi/*file descriptor*/, rsi/*stat address*/)/*success:0, error:negative*/;
	test rax, rax		;
	jnz .fstat_error	;	if(rax != 0)goto .fstat_error;
.close:				;.close:
	mov rax, SYSCALL_CLOSE	;
	pop rdi			;	rdi = (file descriptor); //rsp argc argv[0]
	syscall			;	rax = close(rdi:(file descriptor))/*success:0, error:negative*/;
	cmp rax, 0		;
	jl .close_error		;	if(rax < 0)goto .close_error;
.exit:				;.exit:
	mov rax, SYSCALL_EXIT	;
	xor rdi, rdi		;	//return value
	syscall			;	exit(rdi:0);
.close_error:			;.close_error:
	mov rdi, error_message.close;
	call error		;	error(error_message.close:"CLOSE ERROR!\n");
.fstat_error:			;.fstat_error:
	mov rdi, error_message.fstat;
	call error		;	error(error_message.fstat:"FSTAT ERROR!\n");
.open_error:			;.open_error:
	mov rdi, error_message.open;
	call error		;	error(error_message.open:"OPEN ERROR!\n");
				;}

string_length:			;unsigned long string_length(char *rdi:string, unsigned long rsi:max_length)
				;{
	xor rax, rax		;	rax/*total checked bytes*/ = 0;
.check_8_bytes:			;.check_8_bytes:
	mov rdx, qword[rdi]	;	unsigned long rdx = *(long *)rdi:string;
	xor rcx, rcx		;	rcx/*num of checked bytes in rdx*/ = 0;
.check_1_byte:			;.check_1_byte:
	test dl, dl		;
	jz .end			;	if(rl == 0)goto .end;
	inc rax			;	rax/*total checked bytes*/++;
	cmp rax, rsi		;
	je .end			;	if(rax/*total checked bytes*/ == rsi:max_length)goto .end;
	shr rdx, 8		;	rdx >>= 8;
	inc rcx			;	rcx/*num of checked bytes in rdx*/++;
	cmp rcx, 8		;
	jne .check_1_byte	;	if(rcx/*num of checked bytes in rdx*/ != 8)goto .check_1_byte:
	add rdi, 8		;	rdi:string += 8;
	jmp .check_8_bytes	;	goto .check_8_bytes;
.end:				;.end:
	ret			;	return rax;
				;}

