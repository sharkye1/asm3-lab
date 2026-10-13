%include "colon.inc"
%include "dict.inc"
%include "lib.inc"

section .data

colon dicts, "1", demo  
colon dicts, "2", demo2

colon demo, "hello", "Hello from NASM macro"
colon demo2, "world", "World from NASM macro"
colon demo, "a", "1"
colon demo2, "b", "2"
colon demo, "c", "3"
colon demo2, "d", "4"
colon demo, "e", "5"

demo_head:  dq demo_current     
demo2_head: dq demo2_current
dicts_head: dq dicts_current

name1: db "1", 0
name2: db "2", 0

section .text
global _start

_start:
    mov rdi, name1         
    mov rsi, dicts_head    
    call print_dict_by_name

    call print_newline

    mov rdi, name2
    mov rsi, dicts_head
    call print_dict_by_name 

    xor edi, edi
    call exit