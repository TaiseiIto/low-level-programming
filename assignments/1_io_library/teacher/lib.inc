section .text

exit: 
    xor rdi, rdi
    mov rax, 60
    syscall

string_length:
    xor rax, rax
.loop:
    cmp byte [rdi+rax], 0
    je .end 
    inc rax
    jmp .loop 
.end:
    ret

print_char:
    push rdi
    mov rdi, rsp
    call print_string 
    pop rdi
    ret

print_newline:
    mov rdi, 10
    jmp print_char

print_string:
    push rdi
    call string_length
    pop rsi
    mov rdx, rax 
    mov rax, 1
    mov rdi, 1 
    syscall
    ret

print_uint:
    mov rax, rdi
    mov rdi, rsp
    push 0
    sub rsp, 16
    
    dec rdi
    mov r8, 10

.loop:
    xor rdx, rdx
    div r8
    or  dl, 0x30
    dec rdi 
    mov [rdi], dl
    test rax, rax
    jnz .loop 
   
    call print_string
    
    add rsp, 24
    ret

print_int:
    test rdi, rdi
    jns print_uint
    push rdi
    mov rdi, '-'
    call print_char
    pop rdi
    neg rdi
    jmp print_uint

; returns rax: number, rdx : length
parse_int:
    mov al, byte [rdi]
    cmp al, '-'
    je .signed
    jmp parse_uint
.signed:
    inc rdi
    call parse_uint
    neg rax
    test rdx, rdx
    jz .error

    inc rdx
    ret

    .error:
    xor rax, rax
    ret 

; returns rax: number, rdx : length
parse_uint:
    mov r8, 10
    xor rax, rax
    xor rcx, rcx
.loop:
    movzx r9, byte [rdi + rcx] 
    cmp r9b, '0'
    jb .end
    cmp r9b, '9'
    ja .end
    xor rdx, rdx 
    mul r8
    and r9b, 0x0f
    add rax, r9
    inc rcx 
    jmp .loop 
    .end:
    mov rdx, rcx
    ret

string_equals:
    mov al, byte [rdi]
    cmp al, byte [rsi]
    jne .no
    inc rdi
    inc rsi
    test al, al
    jnz string_equals
    mov rax, 1
    ret
    .no:
    xor rax, rax
    ret 


read_char:
    push 0
    xor rax, rax
    xor rdi, rdi
    mov rsi, rsp 
    mov rdx, 1
    syscall
    pop rax
    ret 

read_word:
    push r14			;r14は読んだバイト数
    push r15			;r15はバッファサイズ
    xor r14, r14 		;r14(読んだバイト数)を0で初期化
    mov r15, rsi		;r15にバッファサイズを格納
    dec r15			;r15(バッファサイズ)から終端文字の領域を差し引く

    .A:
    push rdi			;rdi(バッファアドレス)を退避
    call read_char		;rax = 1バイト読み込み
    pop rdi			;rdi(バッファアドレス)を復元
    cmp al, ' '			;rax(最近読んだ文字)がスペースならば.Aに戻って1バイト先を読み取る
    je .A
    cmp al, 10			;raxが改行ならば.Aに戻って1バイト先を読み取る
    je .A
    cmp al, 13			;raxがCRならば.Aに戻って1バイト先を読み取る
    je .A 
    cmp al, 9 			;raxがタブならば.Aに戻って1バイト先を読み取る
    je .A
    test al, al			;raxが終端文字ならば.Cに飛んで
    jz .C

    .B:
    mov byte [rdi + r14], al	;最近読み取った文字をバッファに格納
    inc r14			;r14(読んだバイト数)をインクリメント

    push rdi			;rdi(バッファアドレス)を退避
    call read_char		;rax = 1バイト読み込み
    pop rdi			;rdi(バッファアドレス)復元
    cmp al, ' '			;rax(最近読んだ文字)がスペースならば.Cに飛ぶ
    je .C
    cmp al, 10			;raxが改行ならば.Cに飛ぶ
    je .C
    cmp al, 13			;raxがCRならば.Cに飛ぶ
    je .C 
    cmp al, 9			;raxがタブならば.Cに飛ぶ
    je .C
    test al, al			;raxが終端文字ならば.Cに飛ぶ
    jz .C
    cmp r14, r15		;バッファサイズが限界を迎えたら.Dに飛ぶ
    je .D

    jmp .B

    .C:				;読み込みが終わった
    mov byte [rdi + r14], 0	;終端文字を追加
    mov rax, rdi 		;rax = 読み込んだ文字列のアドレス
   
    mov rdx, r14 		;rdx = 読み込んだバイト数
    pop r15
    pop r14
    ret

    .D:				;バッファサイズが限界を迎えた
    xor rax, rax		;rax = NULL
    pop r15
    pop r14
    ret

    ; rdi = source
    ; rsi = dest
    ; rdx = dest length 
string_copy:

    push rdi
    push rsi
    push rdx
    call string_length
    pop rdx
    pop rsi
    pop rdi

    cmp rax, rdx
    jae .too_long  ; we also need to store null-terminator
    
    push rsi 

        .loop: 
        mov dl, byte[rdi]
        mov byte[rsi], dl
        inc rdi
        inc rsi
        test dl, dl
        jnz .loop 

    pop rax 
    ret

    .too_long:
    xor rax, rax
    ret
