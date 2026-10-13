%include "lib.inc"

section .text
global find_word
global print_dict
global print_dict_by_name

; struct node *find_word(const char *key, struct node **head)
; rdi - искомая строка, rsi - адрес переменной-головы словаря.
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

; void print_dict(struct node **head)
; rdi - адрес переменной-головы словаря
print_dict:
    push r12
    mov r12, [rdi]
.loop:
    test r12, r12
    jz .done
    mov rdi, [r12 + 8]
    call print_string
    mov rdi, colon_sep
    call print_string
    mov rdi, [r12 + 16]
    call print_string
    call print_newline
    mov r12, [r12]
    jmp .loop
.done:
    pop r12
    ret

; void print_dict_by_name(const char *name, struct node **dicts)
; rdi - имя словаря, rsi - адрес головы словаря словарей
print_dict_by_name:
    call find_word
    test rax, rax
    jz .not_found
    mov rdi, [rax + 16]
    jmp print_dict
.not_found:
    ret

section .rodata
colon_sep: db ": ", 0
    