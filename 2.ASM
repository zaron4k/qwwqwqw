format PE console
entry start

include 'win32a.inc'

section '.data' data readable writeable
n dd 4
m dd 3

; Массив 4 строки ? 3 столбца = 12 элементов
array dd  1, -2,  3, \
         4,  5, -6, \
        -7,  8,  9, \
        10, -11, 12

fmt_int db "%6d ",0
fmt_line db 13,10,0
msg_wait db 13,10,"Press any key to exit...",13,10,0

section '.code' code readable executable
start:

    ; ===== 1. Заменить максимум в каждой строке на противоположный по знаку =====
    xor esi, esi  ; строка = 0

find_max_in_rows:
    cmp esi, [n]
    jge swap_columns

    mov eax, esi
    imul eax, [m]
    shl eax, 2
    mov edi, array
    add edi, eax  ; edi = указатель на строку i

    mov ebx, [edi] ; начальный максимум
    xor ecx, ecx   ; индекс макс
    mov edx, 1     ; j = 1

.find_max_loop:
    cmp edx, [m]
    jge .found_max

    mov ebp, edx
    shl ebp, 2
    mov eax, [edi + ebp]
    cmp eax, ebx
    jle .next_j
    mov ebx, eax
    mov ecx, edx
.next_j:
    inc edx
    jmp .find_max_loop

.found_max:
    mov ebp, ecx
    shl ebp, 2
    mov eax, [edi + ebp]
    neg eax
    mov [edi + ebp], eax

    inc esi
    jmp find_max_in_rows

    ; ===== 2. Поменять местами первый и последний столбцы =====
swap_columns:
    xor esi, esi

swap_loop:
    cmp esi, [n]
    jge print_array

    mov eax, esi
    imul eax, [m]
    shl eax, 2
    mov edi, array
    add edi, eax  ; edi -> строка i

    ; обмен array[i][0] и array[i][m-1]
    mov eax, [edi]
    mov ecx, [m]
    dec ecx
    shl ecx, 2
    mov ebx, [edi + ecx]
    mov [edi], ebx
    mov [edi + ecx], eax

    inc esi
    jmp swap_loop

    ; ===== 3. Вывод массива =====
print_array:
    xor esi, esi

print_row:
    cmp esi, [n]
    jge done

    xor ecx, ecx

print_col:
    cmp ecx, [m]
    jge print_newline

    mov eax, esi
    imul eax, [m]
    add eax, ecx
    shl eax, 2
    mov ebx, [array + eax]

    push ebx
    push fmt_int
    call [printf]
    add esp, 8

    inc ecx
    jmp print_col

print_newline:
    push fmt_line
    call [printf]
    inc esi
    jmp print_row

done:
    ; Пауза — ждём нажатие клавиши
    push msg_wait
    call [printf]
    call [getchar]
    invoke ExitProcess, 0

section '.idata' import data readable
library kernel32,'kernel32.dll',\
        msvcrt,'msvcrt.dll'

import kernel32,\
       ExitProcess,'ExitProcess'

import msvcrt,\
       printf,'printf',\
       getchar,'getchar'
