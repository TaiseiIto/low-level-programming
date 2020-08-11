section .data

newline_char: db 0x0a			;char *newline_char = "\n";

codes: db '0123456789ABCDEF'		;char *codes = "0123456789ABCDEF";

section .text
global _start

print_newline:				;ssize_t print_newline(void)
					;{
	mov rax, 1			;	rax = 1:write system call ID;
	mov rdi, 1			;	rdi = 1:stdout;
	mov rsi, newline_char		;	rsi = newline_char:"\n";
	mov rdx, 1			;	rdx = 1:strlen(rsi:newline_char:"\n");
	syscall				;	rax = write(rdi:stdout, rsi:newline_char:"\n", rdx:1:strlen(rsi:newline_char:"\n")):(num of written bytes):1;
	ret				;	return rax:(num of written bytes):1;
					;}

print_hex:				;print_hex(unsigned int hex)
					;{
	mov rax, rdi			;	rax = rdi:hex;
	mov rdi, 1			;	rdi = 1:stdout;
	mov rdx, 1			;	rdx = 1:(num of bytes of a digit of hex);
	mov rcx, 64			;	rcx = 64:(num of digits of hex);
iterate:				;iterate://print a digit of hex
	push rax			;	*(rsp -= 8) = rax:hex;
	sub rcx, 4			;	rcx:(print a digit from rcx to rcx + 3 bit) -= 4;//go to next digit printing
	sar rax, cl			;	rax >> cl;
	and rax, 0xf			;	rax &= 0x000000000000000f;//get a target digit from hex
	lea rsi, [codes + rax]		;	rsi = codes:"0123456789ABCDEF" + rax:target digit;
	mov rax, 1			;	rax = 1:(write system call ID);
	push rcx			;	*(rsp -= 8) = rcx;//system call change rcx;
	syscall				;	rax = write(rdi:1:stdout, rsi:(codes:"0123456789ABCDEF" + rax:target digit):(digit char addr), rdx:1:(num of bytes of a digit of hex)):(num of written bytes):1;
	pop rcx				;	rcx = *rsp;rsp += 8;//recover rcx:(print a digit from rcx to rcx + 3 bit)
	pop rax				;	rax = *rsp:hex;rsp += 8;
	test rcx, rcx			;	//calculate rcx & rcx
	jnz iterate			;	//if((rcx & rcx != 0):(rcx != 0))goto iterate;
	ret				;	return rax:hex;
					;}

_start:					;int main(void)
					;{
	mov rdi, 0x0123456789abcdef	;	rdi = 0x0123456789abcdef;
	call print_hex			;	rax = print_hex(rdi:0x0123456789abcdef):0x0123456789abcdef;
	call print_newline		;	rax = print_newline():1;
	mov rax, 60			;	rax = 60:(exit system call ID);
	xor rdi, rdi			;	(rdi ^= rdi):(rdi = 0);
	syscall				;	return rdi:0;
					;}

