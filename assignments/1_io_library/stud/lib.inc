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

section .data
error_message: db 'ERROR!', 0x00

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

print_char:			;unsigned long:(num of written bytes):1 print_char(char rdi:character)//print char to stdout
				;{
    push rdi			;	*(rsp -= 8) = rdi:character;
    mov rax, syscall_write	;	rax = syscall_write;
    mov rdi, stdout		;	rdi = stdout;
    mov rsi, rsp		;	rsi = rsp:&character;
    mov rdx, 1			;	rdx = 1:(num of written bytes);
    syscall			;	rax = write(rdi:stdout, rsi:&character, rdx:1:(num of written bytes)):(num of written bytes);
    pop rdi			;	rdi = (*rsp):character; rsp += 8;
    ret				;	return rax:(num of written bytes):1;
				;}

print_newline:
    xor rax, rax
    ret


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
    mov rax, 7			;	rax = 7;
    mov rdx, rax		;	rdx = rax:7;
    jmp .shift_last_8_decimal_digits;	goto .shift_last_8_decimal_digits;
				;}


print_int:			;void print_int(long rdi:integer)//print integer by decimal system
				;{
    mov rax, 1			;	if(rdi:integer < 0)goto .positive
    shl rax, 63			;
    test rdi, rax		;
    jz .positive
    mov rax, char_minus		;	rax = '-';
    push rdi			;	*(rsp -= 8) = rdi:integer;
    push rax			;	*(rsp -= 8) = rax;
    mov rax, syscall_write	;	rax = syscall_write;
    mov rdi, stdout		;	rdi = stdout;
    mov rsi, rsp		;	rsi = rsp:"-";
    mov rdx, 1			;	rdx = 1;
    syscall			;	rax = write(rdi:stdout, rsi:"-", rdx:1):1;
    pop rax			;	rax = *rsp:'-'; rsp += 8;
    pop rdi			;	rdi = *rsp:integer; rsp += 8;
    neg rdi			;	rdi *= -1;
.positive:			;.positive:
    call print_uint		;	print_uint(rdi:(unsigned integer));
    ret				;	return;
				;}

string_equals:
    xor rax, rax
    ret


read_char:			;char read_char(void)//read char from stdin
				;{
    xor rax, rax		;	rax = 0;
    push rax			;	*(rsp -= 8) = rax:0;
    mov rax, syscall_read	;	rax = syscall_read;
    mov rdi, stdin		;	rdi = stdin;
    mov rsi, rsp		;	rsi = rsp:"";
    mov rdx, 1			;	rdx = 1;
    syscall			;	rax = read(rdi:stdin, rsi:rsp:"", rdx:1):(num of read bytes);
    pop rax			;	rax = *rsp; rsp += 8;
    ret 			;	return rax;
				;}

read_word:			;char *read_word(char *rdi:buf, unsigned long rsi:sz):(if success, buf. else NULL),rdx:(length of word)//read word consisting of char except ' ', '\t', '\a' and CR
				;{
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
    test rax, rax		;	if(!rax:(num of read bytes))goto .success;
    jz .success
    cmp byte[rsi], char_carriage_return;if(*rsi == 0x0d)goto .whitespace;
    je .whitespace		;
    cmp byte[rsi], char_new_line;	if(*rsi == '\n')goto .whitespace;
    je .whitespace		;
    cmp byte[rsi], char_null	;	if(*rsi == '\0')goto .success;
    je .success			;
    cmp byte[rsi], char_space	;	if(*rsi == ' ')goto .whitespace;
    je .whitespace		;
    cmp byte[rsi], char_tab	;	if(*rsi == '\t')goto .whitespace;
    je .whitespace		;
    inc rcx			;	rcx:(num of read bytes)++;
    inc rsi			;	rsi:(buf + rcx)++;
    jmp .read			;	goto .read;
.whitespace:			;.whitespace:
    test rcx, rcx		;	if(rcx != 0)goto .success;
    jnz .success		;
    jmp .read			;	else goto .read;
.success:			;.success:
    mov byte[rsi], 0		;	*rsi = '\0';
    mov rax, r8			;	rax = r8:buf;
    mov rdx, rcx		;	rdx = rcx:(length of word);
    jmp .end			;	goto .end;
.error:				;.error:
    mov rax, 0			;	rax = NULL;
.end:				;.end:
    ret				;	return rax:buf, rdx:(length of word);
				;}

; rdi points to a string
; returns rax: number, rdx : length
parse_uint:
    xor rax, rax
    ret

; rdi points to a string
; returns rax: number, rdx : length
parse_int:
    xor rax, rax
    ret 


string_copy:			;char *string_copy(char *rdi:source, char *rsi:destination, unsigned long rdx:length)//return destination
				;{
    push rdi			;	*(rsp -= 8) = rsi:destination;
.loop_begin:			;	while(1)
				;	{
    cmp rdx, 8			;		if(8 <= rdx:length)goto .copy_qword;
    jae .copy_qword		;
    cmp rdx, 4			;		if(4 <= rdx:length)goto .copy_dword;
    jae .copy_dword		;
    cmp rdx, 2			;		if(2 <= rdx:length)goto .copy_word;
    jae .copy_word		;
.copy_byte:			;.copy_byte://rdx == 1
    mov al, byte[rdi]		;		al = *rdi;
    mov byte[rsi], al		;		*rsi = al;
    jmp .loop_end		;		break;
.copy_word:			;.copy_word://2 <= rdx
    mov ax, word[rdi]		;		ax = *rdi;
    mov word[rsi], ax		;		*rsi = ax;
    add rdi, 2			;		rdi += 2:(word);
    add rsi, 2			;		rsi += 2:(word);
    sub rdx, 2			;		rdx -= 2:(word);
    jz .loop_end		;		if(rdx == 0)goto .loop_end;
    jmp .loop_begin		;		else goto .loop_begin;
.copy_dword:			;.copy_dword://4 <= rdx
    mov eax, dword[rdi]		;		eax = *rdi;
    mov dword[rsi], eax		;		*rsi = eax;
    add rdi, 4			;		rdi += 4:(dword);
    add rsi, 4			;		rsi += 4:(dword);
    sub rdx, 4			;		rdx -= 4:(dword);
    jz .loop_end		;		if(rdx == 0)goto .loop_end;
    jmp .loop_begin		;		else goto .loop_begin;
.copy_qword:			;.copy_qword://8 <= rdx
    mov rax, qword[rdi]		;		rax = *rdi;
    mov qword[rsi], rax		;		*rsi = rax;
    add rdi, 8			;		rdi += 8:(qword);
    add rsi, 8			;		rsi += 8:(qword);
    sub rdx, 8			;		rdx -= 8:(qword);
    jz .loop_end		;		if(rdx == 0)goto .loop_end;
    jmp .loop_begin		;		else goto .loop_begin;
.loop_end:			;	}
    pop rax			;	rax = (*rsp):destination; rsp += 8;
    ret				;	return rax:destication;
				;}
