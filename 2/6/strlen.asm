global _start

section .data

test_string: db "abcdef", 0	;char *test_string = "abcdef";

section .text

strlen:				;unsigned long strlen(char *rdi)
				;{
	xor rax, rax		;	(rax ^= rax):(rax = 0);
.loop:				;.loop:
	cmp byte [rdi+rax], 0	;	//compare rdi[rax] and '\0'
	je .end			;	if(rdi[rax] == '\0')goto .end;
	inc rax			;	rax++;
	jmp .loop		;	goto .loop;
.end:				;.end:
	ret			;	return rax;
				;}

_start:				;int main(void)
				;{
	mov rdi, test_string	;	rdi = test_string:"abcdef";
	call strlen		;	rax = strlen(rdi:test_string:"abcdef"):6;
	mov rdi, rax		;	rdi = rax:strlen(test_string:"abcdef"):6;
	mov rax, 60		;	rax = 60:exit systemcall ID;
	syscall			;	return rdi:strlen(test_string:"abcdef"):6;
				;}
