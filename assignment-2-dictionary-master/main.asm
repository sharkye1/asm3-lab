%include "lib.inc"
%include "dict.inc"
%include "words.inc"

section .rodata
error_message: db "Key not found", 10
error_message_end:

section .bss
input_buffer: resb 256

section .text
global _start
_start:
    mov rdi, input_buffer
    mov esi, 256
    call read_word
    test rax, rax
    jz .not_found

    mov rdi, rax
    mov rsi, dict_a_start
    call find_word
    test rax, rax
    jz .not_found

    mov rdi, [rax + 16]
    call print_string
    call print_newline
    xor edi, edi
    call exit

.not_found:
    mov eax, 1
    mov edi, 2
    mov rsi, error_message
    mov edx, error_message_end - error_message
    syscall
    mov edi, 1
    call exit
