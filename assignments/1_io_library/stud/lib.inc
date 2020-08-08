section .text

string_length:			;unsigned long string_length(char *rdi:string)
				;{
    xor rax, rax		;	rax ^= rax(rax = 0);
.loop_begin:			;	while(1)
				;	{
    cmp byte[rdi + rax], 0x00	;		if(!*rdi:string)break;
    je .loop_end		;
    inc rax			;		rax++;
    jmp .loop_begin		;
.loop_end:			;	}
    ret				;	return rax;
				;}

print_string:			;unsigned long:(num of written bytes) print_string(char *rdi:string)
    xor rax, rax
    ret


print_char:
    xor rax, rax
    ret

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


string_copy:
    ret
