%include "lib.inc"

section .text
global find_word

; struct node *find_word(const char *key, struct node **head)
; rdi -- искомая строка, rsi -- адрес переменной-головы словаря.

find_word:
    mov rdx, [rsi]
.next_node:
    test rdx, rdx
    jz .not_found
    push rdi
    push rdx
    mov rsi, [rdx + 8]
    call string_equals
    pop rdx
    pop rdi
    test eax, eax
    jnz .found
    mov rdx, [rdx]
    jmp .next_node
.found:
    mov rax, rdx
    ret
.not_found:
    xor eax, eax
    ret
    