stdout equ 1
syscall_write equ 1
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
    pop rsi			;	rsp += 8; rsi = (*rsp):string;
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
    pop rdi			;	rsp += 8; rdi = (*rsp):character;
    ret				;	return rax:(num of written bytes):1;
				;}

print_newline:
    xor rax, rax
    ret


print_uint:
    xor rax, rax
    ret


print_int:
    xor rax, rax
    ret

string_equals:
    xor rax, rax
    ret


read_char:
    xor rax, rax
    ret 

read_word:
    ret

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
    pop rax			;	rsp += 8; rax = (*rsp):destination;
    ret				;	return rax:destication;
				;}
