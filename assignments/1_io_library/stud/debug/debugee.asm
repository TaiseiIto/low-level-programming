char_carriage_return equ 0x0d
char_minus equ 0x2d
char_new_line equ 0x0a
char_nine equ 0x39
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

section .data

input: db '-1dasda'

section .text

; rdi points to a string
; returns rax: number, rdx : length
parse_uint:			;{unsigned long rax:(parsed num), unsigned long rdx:(parsed string length)} parse_uint(char *rdi:string)
				;{
    xor rax, rax		;	(rax:(parsed num) ^= rax):(rax = 0);
    xor rdx, rdx		;	(rdx:(parsed string length) ^= rdx):(rdx = 0);
    mov r9, 10			;	r9 = 10;//decimal system
    xor r10, r10		;	(r10:(parsed digit) ^= r10):(r10 = 0);
.parse_8_digits:		;.parse_8_digits:
    mov r8, qword[rdi]		;	char r8[8] = *rdi;
    xor rcx, rcx		;	(rcx:(parse rcx byte of r8) ^= rcx):(rcx = 0);
.parse_1_digit:			;.parse_1_digits:
    cmp r8b, char_zero		;	if(r8[0] < '0')goto .end;
    jb .end
    cmp r8b, char_nine		;	if('9' < r8[0])goto .end;
    ja .end
    push rdx			;	*(rsp -= 8) = rdx;//protect rdx from mul
    mul r9			;	rdx:rax:(parsed num) = rax * r9:10;
    test rdx, rdx		;	if(0 < rdx)goto .too_big;
    jnz .too_big
    pop rdx			;	rdx = *rsp; rsp += 8;//recover rdx
    sub r8b, char_zero		;	r8[0] -= '0';//parsed digit
    mov r10b, r8b		;	r10b = r8[0]:(parsed digit);
    add rax, r10		;	rax:(parsed num) += r10:(parsed digit);
    jc .too_big			;	if(carry_flag)goto .too_big;
    inc rcx			;	rcx:(parse rcx byte of r8)++;
    inc rdx			;	rdx:(parsed string length)++;
    cmp rcx, 8			;	if(rcx:(parse rcx byte of r8) == 8)goto .parse_8_digits;
    je .parse_next_8_digits
    sar r8, 8			;	r8 >>= 8;
    jmp .parse_1_digit		;	goto .parse_1_digit;
.too_big:			;.too_big:
    xor rax, rax		;	(rax:(parsed num) ^= rax):(rax = 0);
    xor rdx, rdx		;	(rdx:(parsed string length) ^= rdx):(rdx = 0);
    ret				;	return {unsigned long rax:(parsed num):0, unsigned long rdx:(parsed string length):0};
.parse_next_8_digits:		;.parse_next_8_digits:
    add rdi, 8			;	rdi:(string address) += 8;
    jmp .parse_8_digits		;	goto .parse_8_digits;
.end:
    ret				;	return {unsigned long rax:(parsed num), unsigned long rdx:(parsed string length)};
				;}

; rdi points to a string
; returns rax: number, rdx : length
parse_int:			;{long rax:(parsed num), unsigned long rdx:(parsed string length)} parse_int(char *rdi:string)
				;{
    cmp byte[rdi], char_minus	;	if(*rdi == '-')goto .minus;
    je .minus
    call parse_uint		;	{rax, rdx} = parse_uint(rdi:string);
    mov r8, 0x8000000000000000	;	r8 = -1;//check range
    test rax, r8		;	if(rax < 0)goto .error;
    jnz .error
    jmp .end			;	else goto .end;
.minus:				;.minus:
    inc rdi			;	rdi:string++;//skip '-'
    call parse_uint		;	{rax, rdx} = parse_uint(rdi:(abs part string));
    mov r8, 0x8000000000000000	;	r8 = -1;//check range
    cmp rax, r8			;	if(0x8000000000000000 rax)goto .error;
    ja .error
    neg rax			;	rax:(parsed num) *= -1;
    inc rdx			;	rdx:(parsed string length)++;
.error:				;.error:
    xor rax, rax		;	(rax:(parsed num) ^= rax):(rax = 0);
    xor rdx, rdx		;	(rdx:(parsed string length) ^= rdx):(rdx = 0);
    ret				;	return {long rax:(parsed num):0, unsigned long rdx:(parsed string length):0};
.end:				;.end:
    ret 			;	return {long rax:(parsed num), unsigned long rdx:(parsed string length)};
				;}

_start:
    mov rdi, input
    call parse_int
    mov rax, syscall_exit
    xor rdi, rdi
    syscall
