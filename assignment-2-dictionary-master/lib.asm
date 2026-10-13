section .text

global string_length
global print_string
global print_error
global print_newline
global string_equals
global read_word
global exit

; size_t string_length(const char *rdi)
string_length:
    xor rax, rax
.length_loop:
    cmp byte [rdi + rax], 0
    je .done
    inc rax
    jmp .length_loop
.done:
    ret

; ssize_t print_string(const char *rdi)
print_string:
    push rdi
    call string_length
    mov rdx, rax
    pop rsi
    mov eax, 1                  ; sys_write
    mov edi, 1                  ; stdout
    syscall
    ret

; ssize_t print_error(const char *rdi)
print_error:
    push rdi
    call string_length
    mov rdx, rax
    pop rsi
    mov eax, 1                  ; sys_write
    mov edi, 2                  ; stderr
    syscall
    ret

; Печатает один перевод строки в stdout.
print_newline:
    mov eax, 1
    mov edi, 1
    mov rsi, newline
    mov edx, 1
    syscall
    ret

; int string_equals(const char *rdi, const char *rsi)
string_equals:
.compare_loop:
    mov al, [rdi]
    cmp al, [rsi]
    jne .not_equal
    test al, al
    jz .equal
    inc rdi
    inc rsi
    jmp .compare_loop
.equal:
    mov eax, 1
    ret
.not_equal:
    xor eax, eax
    ret

; char *read_word(char *rdi, size_t rsi)
; Пропускает начальные пробельные символы, затем читает строку до newline.
; В буфер помещается не более rsi - 1 символов и завершающий ноль.
read_word:
    push rbx
    push r12
    mov rbx, rdi
    mov r12, rsi

    sub rsp, 256
    mov eax, 0                  ; sys_read
    xor edi, edi                ; stdin
    mov rsi, rsp
    mov edx, 256
    syscall
    test rax, rax
    jle .failure
    mov r8, rax                 ; число прочитанных байт
    xor r9d, r9d                ; индекс входа

.skip_spaces:
    cmp r9, r8
    jae .failure
    mov al, [rsp + r9]
    cmp al, ' '
    je .skip_one
    cmp al, 9                   ; tab
    je .skip_one
    cmp al, 10                  ; newline
    je .skip_one
    cmp al, 13                  ; carriage return
    je .skip_one
    jmp .copy_word
.skip_one:
    inc r9
    jmp .skip_spaces

.copy_word:
    xor r10d, r10d
.copy_loop:
    cmp r9, r8
    jae .terminate
    mov al, [rsp + r9]
    cmp al, 10
    je .terminate
    cmp al, 13
    je .terminate
    cmp r10, r12
    jae .failure
    mov [rbx + r10], al
    inc r9
    inc r10
    jmp .copy_loop

.terminate:
    cmp r10, r12
    jae .failure
    mov byte [rbx + r10], 0
    mov rax, rbx
    add rsp, 256
    pop r12
    pop rbx
    ret

.failure:
    add rsp, 256
    xor eax, eax
    pop r12
    pop rbx
    ret

; Завершает процесс с кодом, переданным в rdi.
exit:
    mov eax, 60                 ; sys_exit
    syscall
    ud2

section .rodata
newline: db 10
