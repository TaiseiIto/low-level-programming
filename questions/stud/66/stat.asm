%define CHAR_NEWLINE 0x0a
%define CHAR_NULL 0x00
%define STDERR 0x0000000000000002
%define SYSCALL_CLOSE 0x0000000000000003
%define SYSCALL_EXIT 0x000000000000003c
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

no_file_name_message: db 'NO FILE NAME!', CHAR_NEWLINE, CHAR_NULL ;char *no_file_name_message = "NO FILE NAME!\n";
close_error_message: db 'CLOSE ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *close_error_message = "CLOSE ERROR!\n";
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
