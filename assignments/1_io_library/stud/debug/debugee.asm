char_carriage_return equ 0x0d
char_minus equ 0x2d
char_new_line equ 0x0a
char_null equ 0x00
char_space equ 0x20
char_tab equ 0x09
char_zero equ 0x30
stdin equ 0
stdout equ 1
syscall_exit equ 60
syscall_read equ 0
syscall_write equ 1

global _start

section .text

string_length:			;unsigned long string_length(char *rdi:string)
				;{
    xor rax, rax		;	(rax ^= rax):(rax = 0);
.loop_begin:			;	while(1)
				;	{
    cmp byte[rdi + rax], 0x00	;		if(!*rdi:string)break;
    je .loop_end		;
    inc rax			;		rax++;
    jmp .loop_begin		;
.loop_end:			;	}
    ret				;	return rax;
				;}

print_string:			;unsigned long:(num of written bytes) print_string(char *rdi:string)//print string to stdout
				;{
    push rdi			;	*(rsp -= 8) = rdi:string;
    call string_length		;	rax = string_length(rdi:string);
    mov rdx, rax		;	rdx = rax:string_length(string);
    mov rax, syscall_write	;	rax = syscall_write;
    mov rdi, stdout		;	rdi = stdout;
    pop rsi			;	rsi = (*rsp):string; rsp += 8;
    syscall			;	rax = write(rdi:stdout, rsi:string, rdx:string_length(string)):(num of written bytes);
    ret				;	return rax:(num of written bytes);
				;}

print_uint:			;void print_uint(unsigned long rdi:integer)//print unsigned integer by decimal system
				;{
    push rbp			;	*(rsp -= 8) = rbp;
    mov rbp, rsp		;	rbp = rsp;
    mov rax, rdi		;	rax = rdi:integer;
    mov r8, 10			;	r8:divisor = 10;
    xor r9, r9			;	r9:(8 decimal digits) = 0;
    test rax, rax		;	if(rax:integer == 0)goto .print_zero;
    jz .print_zero;
    mov rcx, 1			;	rcx:(num of stored r9:(8 decimal digits) bytes) = 1;
.division_begin:		;.division_begin:
    test rax, rax		;	if(rax == 0)goto .division_end;
    jz .division_end		;
    xor rdx, rdx		;	(rdx ^= rdx):(rdx = 0);
    div r8			;	rdx = rax:rdi % r8:10; rax = rax:rdi / r8:10;
    shl r9, 8			;	r9 <<= 8;
    add r9b, dl			;	r9 += rdx:remainder;
    add r9b, char_zero		;	r9 += '0';
    inc rcx			;	rcx++;
    cmp rcx, 8			;	if(rcx != 8)goto .division_begin;
    jne .division_begin		;
    push r9			;	*(rsp -= 8) = r9:(8 decimal digits);
    xor rcx, rcx		;	rcx = 0;
    jmp .division_begin		;	goto .division_begin;
.division_end:			;.division_end:
    xor rax, rax		;	rax = 0;
    test rcx, rcx		;	if(!rcx)goto .print;
    jz .print			;
    mov rax, 8			;	rax = 8;
    sub rax, rcx		;	(rax -= rcx):(rax = 8 - rcx);
    mov rdx, rax		;	rdx = rax:(8 - rcx);
    shl rdx, 3			;	(rdx <<= 3):(rdx = 8 * (8 - rcx));
.shift_last_8_decimal_digits:	;.shift_last_8_decimal_digits
    sal r9, 1			;	r9 <<= rdx:(8 * (8 - rcx));
    dec rdx			;
    jnz .shift_last_8_decimal_digits;
    push r9			;	*(rsp -= 8) = r9:(rcx decimal digits);
.print:				;.print
    mov rdi, rsp		;	rdi = rsp;
    add rdi, rax		;	(rdi += rax):(rdi = address of decimal string);
    call print_string		;	print_string(rdi:(address of decimal string));
    leave			;	rsp = rbp; rbp = *rsp; rsp -= 8;
    ret				;	return;
.print_zero:			;.print_zero:
    mov r9b, char_zero		;	r9b = '0';
    mov rax, 7			;	rax = 7:(num of blank bytes of r9);
    mov rdx, 56			;	rdx = 56:(num of blank bits of r9);
    jmp .shift_last_8_decimal_digits;	goto .shift_last_8_decimal_digits;
				;}

_start:
    xor rdi, rdi
    call print_uint
    mov rax, syscall_exit
    xor rdi, rdi
    syscall
