%ifndef WORDS_INC
%define WORDS_INC

%include "colon.inc"

section .data

; Первый независимый словарь.
%xdefine dict_a_current 0
colon dict_a, "cat", "a small kitik"
colon dict_a, "dog", "a loyal animal"
colon dict_a, "bird", "a flying animal"
dict_a_head: dq dict_a_current

; Второй независимый словарь. Его узлы не связаны с dict_a.
%xdefine dict_b_current 0
colon dict_b, "red", "a primary color"
colon dict_b, "blue", "another primary color"
dict_b_head: dq dict_b_current

global dict_a_start
global dict_b_start
dict_a_start equ dict_a_head
dict_b_start equ dict_b_head

%endif
