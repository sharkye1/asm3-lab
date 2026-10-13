; Подключаем реализацию макроса colon
%include "colon.inc"

section .data

%xdefine demo_current 0

colon dicts, "1", demo
colon dicts, "2", demo2

colon demo, "hello", "Hello from NASM macro"
colon demo2, "world", "World from NASM macro"
colon demo, "a", "1"
colon demo2, "b", "2"
colon demo, "c", "3"
colon demo2, "d", "4"
colon demo, "e", "5"



demo_head:
    dq demo_current 

section .text
global _start

_start:
    mov eax, 60
    xor edi, edi
    syscall