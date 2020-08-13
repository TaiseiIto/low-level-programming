%define CHAR_NEWLINE 0x0a
%define CHAR_NINE 0x39
%define CHAR_NULL 0x00
%define CHAR_ZERO 0x30
%define MAP_PRIVATE 0x0000000000000002
%define PROT_READ 0x0000000000000001
%define STDERR 0x0000000000000002
%define STDOUT 0x0000000000000001
%define SYSCALL_CLOSE 0x0000000000000003
%define SYSCALL_EXIT 0x000000000000003c
%define SYSCALL_FSTAT 0x0000000000000005
%define SYSCALL_MMAP 0x0000000000000009
%define SYSCALL_MUMAP 0x000000000000000b
%define SYSCALL_OPEN 0x0000000000000002
%define SYSCALL_WRITE 0x0000000000000001

global _start

section .data

error_message:
.close: db 'CLOSE ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *error_message.close = "CLOSE ERROR!\n";
.fstat: db 'FSTAT ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *error_message.fstat = "FSTAT ERROR!\n";
.mmap: db 'MMAP ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *error_message.mmap = "MMAP ERROR!\n";
.mumap: db 'MUMAP ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *error_message.mumap = "MUMAP ERROR!\n";
.no_file_name: db 'NO FILE NAME!', CHAR_NEWLINE, CHAR_NULL ;char *error_message.no_file_name = "NO FILE NAME!\n";
.open: db 'OPEN ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *error_message.open = "OPEN ERROR!\n";
.too_big: db 'TOO BIG!', CHAR_NEWLINE, CHAR_NULL ;char *error_message.too_big = "TOO BIG!\n";
.write: db 'WRITE ERROR!', CHAR_NEWLINE, CHAR_NULL ;char *error_message.write = "WRITE ERROR!\n";

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

is_prime:			;bool is_prime(unsigned long rdi:n)
				;{
	cmp rdi, 1		;
	je .return_false	;	if(rdi:n == 1)goto .return_false;
	cmp rdi, 2		;
	je .return_true		;	if(rdi:n == 2)goto .return_true;
	test rdi, 1		;
	jz .return_false	;	if(rdi:n % 2 == 0)goto .return_false;
	mov rcx, 3		;	rcx/*divisor*/ = 3;
.division:			;.division:
	mov rax, rcx		;	rax = rcx/*divisor*/;
	mul rcx			;	(rdx:rax) = rax/*divisor*/ * rcx/*divisor*/;
	cmp rax, rdi		;
	ja .return_true		;	if(rax/*divisor^2*/ > rdi:n)goto .return_true;
	mov rax, rdi		;	rax = rdi:n;
	div rcx			;	(new rax) = (old rax):n / rcx/*divisor*/; (new rdx) = (old rax):n % rcx/*divisor*/;
	test rdx, rdx		;
	jz .return_false	;	if(rdx/*remainder*/ == 0)goto .return_false;
	add rcx, 2		;	rcx/*divisor*/ += 2;
	jmp .division		;	goto .division:
.return_true:			;.return_true:
	mov rax, 1		;
	ret			;	return 1;
.return_false:			;.return_false:
	xor rax, rax		;
	ret			;	return 0;
				;}

parse_uint:			;unsigned long parse_uint(char *rdi:string)
				;{
	xor rax, rax		;	rax/*parsed integer*/ = 0;
	mov r8, 10		;	r8/*decimal parse*/ = 10;
.check_8_bytes:			;.check_8_bytes:
	mov rdx, qword[rdi]	;	unsigned long rdx/*8 bytes of string*/ = *(long *)rdi:string;
	xor rcx, rcx		;	rcx/*num of checked bytes in rdx*/ = 0;
.check_1_byte:			;.check_1_byte:
	cmp dl, CHAR_ZERO	;
	jb .end			;	if(dl < '0')goto .end;
	cmp dl, CHAR_NINE	;
	ja .end			;	if('9' < dl)goto .end;
	push rdx		;	//rsp /*8 bytes of string*/
	mul r8			;	(rdx:rax) = r8:10 * rax;
	test rdx, rdx		;
	jnz .too_big		;	if(rdx != 0)goto .too_big;
	pop rdx			;	rdx = (8 bytes of string);//rsp
	mov r9, rdx		;	r9/*1 digit*/ = rdx/*8 bytes of string*/;
	and r9, 0xff		;	r9/*1 digit*/ &= 0xff;
	sub r9, CHAR_ZERO	;	r9/*1 digit*/ -= '0';
	add rax, r9		;	rax/*parsed integer*/ += r9/*1 digit*/;
	jc .too_big		;	if(carry flag)goto .too_big;
	shr rdx, 8		;	rdx >>= 8;
	inc rcx			;	rcx/*num of checked bytes in rdx*/++;
	cmp rcx, 8		;
	jne .check_1_byte	;	if(rcx/*num of checked bytes in rdx*/ != 8)goto .check_1_byte:
	add rdi, 8		;	rdi:string += 8;
	jmp .check_8_bytes	;	goto .check_8_bytes;
.end:				;.end:
	ret			;	return rax;
.too_big:			;.too_big:
	mov rdi, error_message.too_big;
	call error		;	error(error_message.too_big:"TOO BIG!\n");
				;}

print_newline:			;void print_newline(void)
				;{
	mov rdi, CHAR_NEWLINE	;	rdi = '\n';

print_char:			;void print_char(char rdi:character)
				;{
	push rdi		;	//rsp (character)
	mov rax, SYSCALL_WRITE	;
	mov rdi, STDOUT		;	//destination file descriptor
	mov rsi, rsp		;	//string address
	mov rdx, 1		;	//length
	syscall			;	rax = write(stdout/*file descriptor*/, rsp:&character/*string*/, 1/*length*/)/*success:num of written bytes, error:negative*/;
	pop rdi			;	rdi = character; //rsp
	cmp rax, 1		;
	jne .write_error	;	if(rax != 1)goto .write_error;
	ret			;	return;
.write_error:			;.write_error:
	mov rdi, error_message.write;
	call error		;	error(error_message.write:"WRITE ERROR!\n");
				;} //end of print_char

				;}//end of print_newline

print_uint:			;void print_uint(unsigned long rdi:integer)
				;{
	push rbp		;	//rsp (old rbp)
	mov rbp, rsp		;	(new rbp) = rsp;
	mov rax, rdi		;	rax = rdi/*integer*/;
	xor rdi, rdi		;	rdi/*8 digits*/ = 0;
	mov rcx, 1		;	rcx/*num of written digits of rdi*/ = 1;
	mov r8, 10		;	r8/*decimal print*/ = 10;
.write_digit:			;.write_digit:
	xor rdx, rdx		;	rdx = 0;
	div r8			;	(new rax) = (old (rdx:rax)) / r8:10; (new rdx) = (old (rdx:rax)) % r8:10;
	shl rdi, 8		;	rdi/*8 digits*/ <<= 8;
	add rdi, rdx		;	rdi/*8 digits*/ += rdx/*remainder of division by r8:10*/;
	add rdi, CHAR_ZERO	;	rdi/*8 digits*/ += '0';
	inc rcx			;	rcx/*num of written digits of rdi*/++;
	test rax, rax		;
	jz .shift_last_8_digits	;	if(rax/*integer*/ == 0)goto .shift_last_8_digits;
	cmp rcx, 8		;
	jnz .write_digit	;	if(rcx != 8)goto .write_1_digit;
	push rdi		;	//rsp (new 8 digits)
	xor rcx, rcx		;	rcx/*num of written digits of rdi*/ = 0;
	jmp .write_digit	;	goto .write_8_digits;
.shift_last_8_digits:		;.shift_last_8_digits:
	cmp rcx, 8		;
	je .print		;	if(rcx == 8)goto .search_address;
	shl rdi, 8		;	rdi/*8 digits*/ <<= 8;
	inc rcx			;	rcx/*num of written digits of rdi*/++;
	inc rax			;	rax/*num of shift*/++;
	jmp .shift_last_8_digits;	goto .shift_last_8_digit;
.print:				;.print:
	push rdi		;	//rsp (new 8 digits)
	mov rdi, rsp		;	rdi/*string address*/ = rsp/*last 8 digits address*/;
	add rdi, rax		;	rdi/*string address*/ += rax/*num of shift*/;
	push rdi		;	//rsp (string address) (last 8 digits)
	mov rsi, -1		;
	call string_length	;	rax = string_length(rdi/*string*/, rsi:-1/*max length*/);
	mov rdx, rax		;	rdx = rax/*string length*/
	mov rax, SYSCALL_WRITE	;
	mov rdi, STDOUT		;
	pop rsi			;	rsi = (string address); //rsp (last 8 digits)
	syscall			;	rax = write(rdi:stdout, rsi:string, rdx/*string length*/)/*success:num of written bytes, error:negative*/;
	cmp rax, rdx		;
	jne .write_error	;	if(rax/*num of written bytes*/ == rdx/*string length*/)goto .write_error;
	leave			;	rsp = rbp; rbp = *rsp/*old rbp*/; rsp += 8;
	ret			;	return;
.write_error:			;.write_error:
	mov rdi, error_message.write;
	call error		;	error(error_message.write:"WRITE ERROR!\n");
				;}

_start:				;int main(void)
				;{
.open:				;.open:
	cmp qword[rsp], 1	;
	je .no_file_name	;	if(argc == 1)goto .no_file_name;
	mov rax, SYSCALL_OPEN	;
	mov rdi, qword[rsp + 16];	//argv[n] == qword[rsp + 8 * n + 8]
	xor rsi, rsi		;	//read only
	xor rdx, rdx		;	//file mode when the file is created novelly
	syscall			;	rax = open(rdi/*file name*/, rsi:0:O_RDONLY/*read only*/, rdx:0/*possessor, possessor group and the other users can't read, write and execute the file created novely*/)/*success:file descriptor, error:negative*/;
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
.mmap:				;.mmap:
	mov rax, SYSCALL_MMAP	;
	xor rdi, rdi		;	//entrust destination address determination to OS
	mov rsi, qword[stat.st_size];	//size
	mov rdx, PROT_READ	;	//readable
	mov r10, MAP_PRIVATE	;	//unshared among other processes
	mov r8, qword[rsp]	;	//file descriptor
	xor r9, r9		;	//offset
	syscall			;	rax = mmap(rdi/*dest addr*/, rsi/*size*/, rdx/*protection flags*/, r10/*flags*/, r8/*file descriptor*/, r9/*offset*/)/*success:dest addr, error:negative*/;
	cmp rax, 0		;
	jl .mmap_error		;	if(rax < 0)goto .mmap_error;
	push rax		;	//rsp (mapped address) (file descriptor) argc argv[0]
.parse_uint:			;.parse_uint:
	mov rdi, qword[rsp]	;
	call parse_uint		;	rax = parse_uint(rdi/*mapped address*/);
.is_prime:			;.is_prime:
	mov rdi, rax		;
	call is_prime		;	rax = is_prime(rdi/*parsed integer*/);
.print_uint:			;.print_uint:
	mov rdi, rax		;
	call print_uint		;	print_uint(rdi/*is_prime*/);
	call print_newline	;	print_newline();
.mumap:				;.mumap:
	mov rax, SYSCALL_MUMAP	;
	pop rdi			;	rdi = (mapped address); //rsp (file descriptor) argc argv[0]
	mov rsi, qword[stat.st_size];	//size
	syscall			;	rax = mumap(rdi/*mapped address*/, rsi/*size*/)/*success:0, error:negative*/;
	test rax, rax		;
	jnz .mumap_error	;	if(rax != 0)goto .mumap_error;
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
.mmap_error:			;.mmap_error:
	mov rdi, error_message.mmap;
	call error		;	error(error_message.mmap:"MMAP ERROR!\n");
.mumap_error:			;.mumap_error:
	mov rdi, error_message.mumap;
	call error		;	error(error_message.mumap:"MUMAP ERROR!\n");
.no_file_name:			;.no_file_name:
	mov rdi, error_message.no_file_name;
	call error		;	error(error_message.no_file_name:"NO FILE NAME!\n");
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

