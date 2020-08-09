global _start

char_0 equ 0x30
stdout equ 1
syscall_write equ 1
syscall_exit equ 60

section .text

print_uint:			;void print_uint(unsigned long rdi:integer)//print integer by decimal system
				;{
    push rbp			;	*(rsp -= 8) = rbp;
    mov rbp, rsp		;	rbp = rsp;
    mov rax, rdi		;	rax = rdi:integer;
    mov r8, 10			;	r8:divisor = 10;
.division_16_digits:		;.division_16_digits:
    mov rcx, 0			;	rcx:(num of stored r9:(16 decimal digits) bits) = 0;
.division_1_digit:		;.division_1_digit:
    xor rdx, rdx		;	(rdx ^= rdx):(rdx = 0);
    div r8			;	rdx = rax:rdi % r8:10; rax = rax:rdi / r8:10;
    shl r9, 4			;	r9 <<= 4;
    add r9b, dl			;	r9 += rdx:remainder;
    add rcx, 4			;	rcx += 4;
    test rax, rax		;	if(rax == 0)goto .print;
    jz .print			;
    cmp rcx, 64			;	if(rcx != 64)goto .division_1_digit;
    jne .division_1_digit	;
    push r9			;	*(rsp -= 8) = r9:(16 decimal digits);
    jmp .division_16_digits	;	goto .division_16_digits;
.print:				;.print
    test rcx, rcx		;	if(rcx == 0)goto .print_next_16_digits;
    jz .print_next_16_digits	;
.print_1_digit:			;.print_1_digit:
    mov r10, r9			;	r10:(decimal digit) = r9;
    and r10, 0x000000000000000f	;	r10 &= 0x000000000000000f;
    add r10, char_0		;	r10 += '0';
    push r10			;	*(rsp -= 8) = r10;
    mov rax, syscall_write	;	rax = syscall_write;
    mov rdi, stdout		;	rdi = stdout;
    mov rsi, rsp		;	rsi = rsp;
    mov rdx, 1			;	rdx = 1;
    push rcx			;	*(rsp -= 8) = rcx;//protect rcx from syscall
    syscall			;	rax = write(rdi:stdout, rsi:&(decimal digit), rdx:1);
    pop rcx			;	rsp += 8; rcx = *rsp;//recover rcx
    pop r10			;	rsp += 8; r10 = *rsp;
    shr r9, 4			;	r9 >>= 4;
    sub rcx, 4			;	rcx -= 4;
    jmp .print			;	goto .print;
.print_next_16_digits:		;.print_next_16_digits:
    cmp rbp, rsp		;	if(rbp == rsp)goto .end;
    je .end			;
    pop r9			;	rsp += 8; r9 = *rsp;
    mov rcx, 64			;	rcx = 64;
    jmp .print_1_digit		;	goto .print_1_digit;
.end:
    pop rbp			;	rsp += 8; rbp = *rsp;
    ret				;	return;
				;}

_start:				;int main(void)
				;{
    mov rdi, 12345		;	print_uint(12345);
    call print_uint		;
    mov rax, syscall_exit	;	exit(0);
    mov rdi, 0			;
    syscall			;
				;}
