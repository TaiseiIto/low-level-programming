global _start

char_carriage_return equ 0x0d
char_minus equ 0x2d
char_new_line equ 0x0a
char_space equ 0x20
char_null equ 0x00
char_tab equ 0x09
char_zero equ 0x30
stdin equ 0
stdout equ 1
syscall_read equ 0
syscall_write equ 1
syscall_exit equ 60

section .text

read_word:			;char *read_word(char *rdi:buf, unsigned long rsi:sz):(if success, buf. else NULL),rdx:(length of word)//read word consisting of char except ' ', '\t', '\a' and CR
				;{
    push rbp			;	*(rsp -= 8) = rbp;
    mov rbp, rsp		;	rbp = rsp;
    mov r8, rdi			;	r8 = rdi:buf;
    mov r9, rsi			;	r9 = rsi:sz;
    test r9, r9			;	if(!r9)goto .error;
    jz .error			;
    dec r9			;	r9--;//r9 = max strlen
    xor rcx, rcx		;	rcx:(num of read bytes) = 0;
    mov rdi, stdin		;	rdi = stdin;
    mov rsi, r8			;	rsi = r8:buf;
    mov rdx, 1			;	rdx = 1;
.read:				;.read:
    cmp rcx, r9			;	if(rcx:(num of read bytes) == r9:(max strlen))goto .error;
    je .error			;
    push rcx			;	*(rsp -= 8) = rcx;//protect rcx from syscall
    mov rax, syscall_read	;	rax = syscall_read;
    syscall			;	rax = read(rdi:stdin, rsi:(buf + rcx), rdx:1):(num of read bytes);
    pop rcx			;	rcx = *rsp; rsp += 8;//recover rcx
    cmp byte[rsi], char_carriage_return;if(*rsi == 0x0d)goto .whitespace;
    je .whitespace		;
    cmp byte[rsi], char_new_line;	if(*rsi == '\n')goto .whitespace;
    je .whitespace		;
    cmp byte[rsi], char_null	;	if(*rsi == '\0')goto .whitespace;
    je .whitespace		;
    cmp byte[rsi], char_space	;	if(*rsi == ' ')goto .whitespace;
    je .whitespace		;
    cmp byte[rsi], char_tab	;	if(*rsi == '\t')goto .whitespace;
    je .whitespace		;
.next_read:			;.next_read:
    inc rcx			;	rcx:(num of read bytes)++;
    inc rsi			;	rsi:(buf + rcx)++;
    jmp .read			;	goto .read;
.whitespace:			;.whitespace:
    test rcx, rcx		;	if(rcx != 0)goto .success;
    jnz .success		;
    jmp .next_read		;	else goto .next_read;
.success:			;.success:
    mov byte[rsi], 0		;	*rsi = '\0';
    mov rax, r8			;	rax = r8:buf;
    mov rdx, rcx		;	rdx = rcx:(length of word);
    jmp .end			;	goto .end;
.error:				;.error:
    mov rax, 0			;	rax = NULL;
    jmp .end			;	goto .end;
.end:
    pop rbp			;	rbp = *rsp; rsp += 8;
    ret				;	return rax:buf, rdx:(length of word);
				;}

_start:				;int main(void)
				;{
    push rbp			;	*(rsp -= 8) = rbp;
    mov rbp, rsp		;	rbp = rsp;
    xor rax, rax		;	rax = 0;
    push rax			;	*(rsp -= 8) = rax:0;
    mov rdi, rsp		;	rdi = rsp;
    mov	rsi, 7			;	rsi = 7;
    call read_word		;	{rax:buf, rdx:sz} = read_word(rdi:rsp:buf, rsi:7:sz);
    pop rax			;	rax = *rsp; rsp += 8;
    pop rbp			;	rbp = *rsp; rsp += 8;
    mov rax, syscall_exit	;	exit(0);
    mov rdi, 0			;
    syscall			;
				;}
