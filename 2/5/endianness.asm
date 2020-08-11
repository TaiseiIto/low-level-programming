section .data

codes: db '0123456789ABCDEF'		;char *codes = "0123456789ABCDEF";

demo1: dq 0x0123456789abcdef		;unsigned long demo1[1] = {0x0123456789ABCDEF};

demo2: db 0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef
					;unsigned char demo2[8] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef};
newline_char: db 0x0a			;char *newline_char = "\n";

section .text
global _start

print_newline:				;long print_newline(void)
					;{
	mov	rax, 1			;
	mov	rdi, 1			;
	mov	rsi, newline_char	;
	mov	rdx, 1			;
	syscall				;	return write(rdi:stdout, rsi:newline_char:"\n", rdx:1:strlen(newline_char:"\n"));
	ret				;}

print_hex:				;long print_hex(unsigned long rdi:hex)
					;{
	mov	rax, rdi		;	rax = rdi:hex;
	mov	rdi, 1			;	rdi = 1:stdout:(file descriptor arg of write syscall);
	mov	rdx, 1			;	rdx = 1(strlen arg of the write syscall);
	mov	rcx, 64			;	rcx = 64:(write a digit of hex from rcx bit to rcx + 3 bit);
iterate:				;iterate:
	push	rax			;	*(rsp -= 8) = rax:hex;
	sub	rcx, 4			;	rcx -= 4;(go to next digit of hex)
	sar	rax, cl			;	rax:hex >>= rcx;(shift target digit to lowest byte)
	and	rax, 0xf		;	rax &= 0xf;(rax = target digit of hex)
	lea	rsi, [codes + rax]	;	rsi = (codes + rax):(letter address of target digit of hex);
	mov	rax, 1			;	rax = 1:(write syscall);
	push	rcx			;	*(rsp -= 8) = rcx;(protect rcx from syscall)
	syscall				;	write(rdi:1:stdout, rsi:(letter addtess of target digit of hex), rdx:1:strlen);
	pop	rcx			;	rsp += 8;rcx = *rsp;(recover rcx)
	pop	rax			;	rsp += 8;rax = *rsp:hex;
	test	rcx, rcx		;	if(rcx != 0)goto iterate;
	jnz	iterate			;
	ret				;	return rax:hex;
					;}

_start:					;long main(void)
					;{
	mov	rdi, [demo1]		;
	call	print_hex		;	print_hex(*demo1:0x0123456789abcdef);
	call	print_newline		;	print_newline();
	mov	rdi, [demo2]		;
	call	print_hex		;	print_hex(*demo2:{0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef});
	call	print_newline		;	print_newline();
	mov	rax, 60			;	exit(0);
	xor	rdi, rdi		;
	syscall				;}

