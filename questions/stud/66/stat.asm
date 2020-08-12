%define CHAR_MINUS 0x2d
%define CHAR_NEWLINE 0x0a
%define CHAR_NULL 0x00
%define CHAR_ZERO 0x30
%define STDERR 0x0000000000000002
%define STDOUT 0x0000000000000001
%define SYSCALL_CLOSE 0x0000000000000003
%define SYSCALL_EXIT 0x000000000000003c
%define SYSCALL_FSTAT 0x0000000000000005
%define SYSCALL_OPEN 0x0000000000000002
%define SYSCALL_WRITE 0x0000000000000001

global _start

section .data

;/usr/include/x86_64-linux-gnu/bits/stat.h
;//x86_64
;struct stat
;  {
;    __dev_t st_dev;		/* Device.  */
;    __ino_t st_ino;		/* File serial number.	*/
;    __nlink_t st_nlink;	/* Link count.  */
;    __mode_t st_mode;		/* File mode.  */
;    __uid_t st_uid;		/* User ID of the file's owner.	*/
;    __gid_t st_gid;		/* Group ID of the file's group.*/
;    int __pad0;
;    __dev_t st_rdev;		/* Device number, if device.  */
;    __off_t st_size;		/* Size of file, in bytes.  */
;    __blksize_t st_blksize;	/* Optimal block size for I/O.  */
;    __blkcnt_t st_blocks;	/* Number 512-byte blocks allocated. */
;    struct timespec st_atim;	/* Time of last access.  */
;    struct timespec st_mtim;	/* Time of last modification.  */
;    struct timespec st_ctim;	/* Time of last status change.  */
;    __syscall_slong_t __glibc_reserved[3];
;  };

;/usr/include/x86_64-linux-gnu/bits/types/struct_timespec.h
;//x86_64
;struct timespec
;{
;  __time_t tv_sec;		/* Seconds.  */
;  __syscall_slong_t tv_nsec;	/* Nanoseconds.  */
;};

;./stat_struct
;st_dev	8bytes
;st_ino	8bytes
;st_nlink	8bytes
;st_mode	4bytes
;st_uid	4bytes
;st_gid	4bytes
;__pad0	4bytes
;st_rdev	8bytes
;st_size	8bytes
;st_blksize	8bytes
;st_blocks	8bytes
;st_atim.tv_sec	8bytes
;st_atim.tv_nsec	8bytes
;__glibc_reserved[0]	8bytes

stat:
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
.__glibc_reserved0:	dq 0x0000000000000000
.__glibc_reserved1:	dq 0x0000000000000000
.__glibc_reserved2:	dq 0x0000000000000000

stat_st_dev_message: db 'stat.st_dev:', CHAR_NULL ;char *stat_st_dev_message = "stat.st_dev";

no_file_name_message: db 'NO FILE NAME!', CHAR_NEWLINE, CHAR_NULL ;char *no_file_name_message = "NO FILE NAME!\n";
close_error_message: db 'CLOSE ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *close_error_message = "CLOSE ERROR!\n";
fstat_error_message: db 'FSTAT ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *fstat_error_message = "FSTAT ERROR!\n";
open_error_message: db 'OPEN ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *open_error_message = "OPEN ERROR!\n";

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

print_int:				;void print_int(long rdi:integer)//print integer by decimal system
					;{
	mov rax, 1			;	if(rdi:integer < 0)goto print_uint
	shl rax, 63			;
	test rdi, rax			;
	jz print_uint
	mov rax, CHAR_MINUS		;	rax = '-';
	push rdi			;	*(rsp -= 8) = rdi:integer;
	push rax			;	*(rsp -= 8) = rax;
	mov rax, SYSCALL_WRITE		;	rax = syscall_write;
	mov rdi, STDOUT			;	rdi = stdout;
	mov rsi, rsp			;	rsi = rsp:"-";
	mov rdx, 1			;	rdx = 1;
	syscall				;	rax = write(rdi:stdout, rsi:"-", rdx:1):1;
	pop rax				;	rax = *rsp:'-'; rsp += 8;
	pop rdi				;	rdi = *rsp:integer; rsp += 8;
	neg rdi				;	rdi *= -1;

print_uint:				;void print_uint(unsigned long rdi:integer)//print unsigned integer by decimal system
					;{
	push rbp			;	*(rsp -= 8) = rbp;
	mov rbp, rsp			;	rbp = rsp;
	mov rax, rdi			;	rax = rdi:integer;
	mov r8, 10			;	r8:divisor = 10;
	xor r9, r9			;	r9:(8 decimal digits) = 0;
	test rax, rax			;	if(rax:integer == 0)goto .print_zero;
	jz .print_zero;
	mov rcx, 1			;	rcx:(num of stored r9:(8 decimal digits) bytes) = 1;
.division_begin:			;.division_begin:
	test rax, rax			;	if(rax == 0)goto .division_end;
	jz .division_end		;
	xor rdx, rdx			;	(rdx ^= rdx):(rdx = 0);
	div r8				;	rdx = rax:rdi % r8:10; rax = rax:rdi / r8:10;
	shl r9, 8			;	r9 <<= 8;
	add r9b, dl			;	r9 += rdx:remainder;
	add r9b, CHAR_ZERO		;	r9 += '0';
	inc rcx				;	rcx++;
	cmp rcx, 8			;	if(rcx != 8)goto .division_begin;
	jne .division_begin		;
	push r9				;	*(rsp -= 8) = r9:(8 decimal digits);
	xor rcx, rcx			;	rcx = 0;
	jmp .division_begin		;	goto .division_begin;
.division_end:				;.division_end:
	xor rax, rax			;	rax = 0;
	test rcx, rcx			;	if(!rcx)goto .print;
	jz .print			;
	mov rax, 8			;	rax = 8;
	sub rax, rcx			;	(rax -= rcx):(rax = 8 - rcx);
	mov rdx, rax			;	rdx = rax:(8 - rcx);
	shl rdx, 3			;	(rdx <<= 3):(rdx = 8 * (8 - rcx));
.shift_last_8_decimal_digits:		;.shift_last_8_decimal_digits
	shl r9, 1			;	r9 <<= rdx:(8 * (8 - rcx));
	dec rdx				;
	jnz .shift_last_8_decimal_digits;
	push r9				;	*(rsp -= 8) = r9:(rcx decimal digits);
.print:					;.print
	mov rdi, rsp			;	rdi = rsp;
	add rdi, rax			;	(rdi += rax):(rdi = address of decimal string);
	call print_string		;	print_string(rdi:(address of decimal string));
	leave				;	rsp = rbp; rbp = *rsp; rsp -= 8;
	ret				;	return;
.print_zero:				;.print_zero:
	mov r9b, CHAR_ZERO		;	r9b = '0';
	mov rax, 7			;	rax = 7:(num of blank bytes of r9);
	mov rdx, 56			;	rdx = 56:(num of blank bits of r9);
	jmp .shift_last_8_decimal_digits;	goto .shift_last_8_decimal_digits;
					;}//end of print_uint

					;}//end of print_int

print_string:				;unsigned long:(num of written bytes) print_string(char *rdi:string)//print string to stdout
					;{
	push rdi			;	*(rsp -= 8) = rdi:string;
	mov rsi, -1			;
	call string_length		;	rax = string_length(rdi:string);
	mov rdx, rax			;	rdx = rax:string_length(string);
	mov rax, SYSCALL_WRITE		;	rax = syscall_write;
	mov rdi, STDOUT			;	rdi = stdout;
	pop rsi				;	rsi = (*rsp):string; rsp += 8;
	syscall				;	rax = write(rdi:stdout, rsi:string, rdx:string_length(string)):(num of written bytes);
	ret				;	return rax:(num of written bytes);
					;}

print_char:				;unsigned long:(num of written bytes):1 print_char(char rdi:character)//print char to stdout
					;{
	push rdi			;	*(rsp -= 8) = rdi:character;
	mov rax, SYSCALL_WRITE		;	rax = syscall_write;
	mov rdi, STDOUT			;	rdi = stdout;
	mov rsi, rsp			;	rsi = rsp:&character;
	mov rdx, 1			;	rdx = 1:(num of written bytes);
	syscall				;	rax = write(rdi:stdout, rsi:&character, rdx:1:(num of written bytes)):(num of written bytes);
	pop rdi				;	rdi = (*rsp):character; rsp += 8;
	ret				;	return rax:(num of written bytes):1;
					;}

print_newline:				;unsigned long:(num of written bytes):1 print_newline(void)//print '\n' to stdout
					;{
	mov rdi, CHAR_NEWLINE		;	rdi = '\n';
	jmp print_char			;	return print_char(rdi:'\n');
					;}

_start:					;int main(int argc, char **argv)
					;{
	cmp qword[rsp], 1		;
	je .no_file_name		;	if(argc == 1)goto .no_file_name;
.open:					;.open:
	mov rax, SYSCALL_OPEN		;
	mov rdi, qword[rsp + 16]	;	rdi = rsp[2];//argv[n] == rsp[1 + n]
	xor rsi, rsi			;	//read only
	xor rdx, rdx			;	//don't create a new file
	syscall				;	rax = open(rdi/*file name*/, rsi/*read only*/, rdx/*permission when a new file is created*/)/*success:file descriptor, error:negative*/;
	cmp rax, 0			;
	jl .open_error			;	if(rax < 0)goto .open_error;
	push rax			;	//stack /*file descriptor*/
.fstat:					;.fstat:
	mov rax, SYSCALL_FSTAT		;
	mov rdi, qword[rsp]		;
	mov rsi, stat			;
	syscall				;	rax = fstat(rdi/*file descriptor*/, rsi/*stat struct addr*/)/*success:0, error:negative*/;
	test rax, rax			;
	jnz .fstat_error		;	if(rax != 0)goto .fstat_error;
	mov rdi, stat_st_dev_message	;
	call print_string		;	print_string(stat_st_dev_message);
	mov rdi, qword[stat.st_dev]	;
	call print_int			;	print_int(stat->st_dev);
	call print_newline		;	print_newline();
.close:					;.close:
	mov rax, SYSCALL_CLOSE		;
	pop rdi				;	rdi = /*file descriptor*/;//stack
	syscall				;	rax = close(rdi/*file descriptor*/)/*success:0, error:negative*/;
	test rax, rax			;
	jnz .close_error		;	if(rax != 0)goto .close_error;
.exit:					;.exit:
	mov rax, SYSCALL_EXIT		;
	xor rdi, rdi			;
	syscall				;	exit(rdi:0);
.no_file_name:				;.no_file_name:
	mov rdi, no_file_name_message	;
	call error			;	error(rdi:no_file_name_message);
.close_error:				;.close_error:
	mov rdi, close_error_message	;
	call error			;	error(rdi:close_error_message);
.fstat_error:				;.close_error:
	mov rdi, fstat_error_message	;
	call error			;	error(rdi:fstat_error_message);
.open_error:				;.open_error:
	mov rdi, open_error_message	;
	call error			;	error(rdi:open_error_message);
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
