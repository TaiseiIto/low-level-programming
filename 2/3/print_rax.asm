; raxレジスタの内容を16進数で表示するプログラム
section .data

codes:
	db '0123456789ABCDEF'		;char *codes = "123456789ABSDEF";

newline:
	db 0x0a				;char *newline = "\n";

section .text

global _start

_start:					;int main(void)
					;{
	mov rax, 0x0123456789abcdef	;	rax = 0x0123456789abcdef;
	mov rdi, 1			;	rdi = 1:stdout;
	mov rdx, 1			;	rdx = 1:(string length argument of write system call);
	mov rcx, 64			;	rcx:(write digits from no.rcx-3 bit to no.rcx bit of rax) = 64:(number of bits of rax);
.loop:					;.loop:
	push rax			;	*(rsp -= 8) = rax:0x0123456789abcdef;
	sub rcx, 4			;	rcx:(write digits from no.rcx-3 bit to no.rcx bit of rax) -= 4:(num of bits in a digit of hexadecimal);
	sar rax, cl			;	rax:0x0123456789abcdef >>= cl:(write digits from no.rcx-3 bit to no.rcx bit of rax);
	and rax, 0x000000000000000f	;	(rax &= 0x000000000000000f):(rax = digits from no.rcx-3 bit to no.rcx bit of 0x0123456789abcdef);
	lea rsi, [codes + rax]		;	rsi = (codes + rax):(hexadecimal digit char address);
	mov rax, 1			;	rax = 1:(write system call ID);
	push rcx			;	*(rsp -= 8) = rcx;//system call overwrites rcx
	syscall				;	rax = write(rdi:1:stdout, rsi:(codes + rax):(hexadecimal digit char address), rdx:1:(string length));
	pop rcx				;	rcx = *rsp; rsp += 8;//restore rcx
	pop rax				;	rax = *rsp:0x0123456789abcdef;rsp += 8;//restore rax
	test rcx, rcx			;	//calculate rcx & rcx
	jnz .loop			;	if(rcx & rcx != 0)goto .loop;
	mov rax, 1			;	rax = 1:(write system call ID);
	lea rsi, [newline]		;	rsi = newline:"\n";
	syscall				;	rax = write(rdi:1:stdout, rsi:newline:"\n", rdx:1:(string length));
	mov rax, 60			;	rax = 60:(exit system call ID);
	xor rdi, rdi			;	(rdi ^= rdi):(rdi = 0);//return value of main
	syscall				;	return rdi:0;
					;}

