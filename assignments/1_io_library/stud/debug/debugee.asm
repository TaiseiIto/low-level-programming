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

str1: db 'ashdb asdhabs dahb', 0
str2: db 'ashdb asdhabs dahb!!', 0

section .text

string_equals:			;bool string_equals(char *rdi, char *rsi)
				;{
.compare_8_bytes:		;.compare_8_bytes:
    mov r8, qword[rdi]		;	char r8[8] = *rdi;
    mov r9, qword[rsi]		;	char r9[8] = *rsi;
    xor rcx, rcx		;	(rcx ^= rcx):(rcx = 0);//num of compared bytes
.compare_1_byte:		;.compare_1_byte:
    cmp r8b, r9b		;	if(r8[0] != r9[0])goto .false;
    jne .false
    test r8b, 0			;	if(r8[0] == '\0')goto .true;
    jz .true
    inc rcx			;	rcx:(num of compared bytes)++;
    cmp rcx, 8			;	if(rcx == 8)goto .compare_next_8_bytes;
    je .compare_next_8_bytes
.compare_next_8_bytes:		;.compare_next_8_bytes:
    add rdi, 8			;	rdi += 8;
    add rsi, 8			;	rsi += 8;
    jmp .compare_8_bytes	;	goto .compare_8_bytes;
.true:				;.true:
    mov rax, 1			;	rax = 1;
    ret				;	return rax:1;
.false:				;.false:
    xor rax, rax		;	(rax ^= rax):(rax = 0);
    ret				;	return rax:0;
				;}


_start:
    mov rdi, str1
    mov rsi, str2
    call string_equals
    mov rax, syscall_exit
    xor rdi, rdi
    syscall
