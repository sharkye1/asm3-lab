#!/usr/bin/env bash
set -euo pipefail

# Создаёт временный words.inc из аргументов вида:
#   "ключ=значение"
# Затем собирает такой словарь с текущими dict.asm и lib.asm.
#
# Пример:
#   ./test_custom.sh \
#       "third word=third word explanation" \
#       "first word=first word explanation"

if (( $# == 0 )); then
    printf 'Использование: %s "ключ=значение" ...\n' "$0" >&2
    exit 2
fi

root_dir=$(cd -- "$(dirname -- "$0")" && pwd)
tmp_dir=$(mktemp -d)
trap 'rm -rf -- "$tmp_dir"' EXIT
index=0

escape_nasm_string() {
    local value=$1
    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    printf '%s' "$value"
}

{
    printf '%%include "colon.inc"\n\n'
    printf 'section .data\n\n'
    printf '%%xdefine dict_a_current 0\n'

    for item in "$@"; do
        if [[ $item != *=* ]]; then
            printf 'Аргумент не имеет формата ключ=значение: %s\n' "$item" >&2
            exit 2
        fi
        key=${item%%=*}
        value=${item#*=}
        if [[ -z $key || -z $value ]]; then
            printf 'Ключ и значение не могут быть пустыми: %s\n' "$item" >&2
            exit 2
        fi

        # Метка значения должна быть допустимым идентификатором NASM.
        index=$((index + 1))
        printf 'colon dict_a, "%s", custom_value_%d, "%s"\n' \
            "$(escape_nasm_string "$key")" "$index" \
            "$(escape_nasm_string "$value")"
    done

    printf 'dict_a_head: dq dict_a_current\n'
    printf 'global dict_a_start\n'
    printf 'dict_a_start equ dict_a_head\n'
} > "$tmp_dir/words.inc"

cat > "$tmp_dir/main.asm" <<'ASM'
%include "lib.inc"
%include "dict.inc"
%include "words.inc"

section .rodata
error_message: db "Key not found", 10

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
    mov edi, 1
    call exit
ASM

(
    cd "$tmp_dir"
    nasm -f elf64 -I "$root_dir/" -o main.o main.asm
    nasm -f elf64 -I "$root_dir/" -o dict.o "$root_dir/dict.asm"
    nasm -f elf64 -I "$root_dir/" -o lib.o "$root_dir/lib.asm"
    ld -o custom_dict main.o dict.o lib.o
    printf '%s\n' "Временный словарь собран. Введите ключ или Ctrl-D:"
    ./custom_dict
)
