format PE console
entry start

include 'win32a.inc'

section '.data' data readable writeable
array dd 12 dup(0)

prompt_input_rows db "Enter 12 integers (3 rows, 4 columns), row-wise:",13,10,0
prompt_input_cols db "Enter 3 integers for the 4th column (top to bottom):",13,10,0

fmt_scanf db "%d",0
fmt_int   db "%4d ",0
fmt_line  db 13,10,0
fmt_title db "Modified array:",13,10,0
fmt_sum   db 13,10,"Sum of positives: %d",13,10,0
fmt_neg   db "Negative count: %d",13,10,0
msg_wait  db 13,10,"Press any key to exit...",13,10,0

sum       dd 0
neg_count dd 0

section '.code' code readable executable
start:

    ; Ввод первых 12 чисел (заполнение по строкам)
    push prompt_input_rows
    call [printf]

    mov ecx, 0
.read_rows:
    cmp ecx, 12
    jge .done_rows

    mov eax, ecx
    shl eax, 2
    lea edx, [array]
    add edx, eax

    push edx
    push fmt_scanf
    call [scanf]
    add esp, 8

    inc ecx
    jmp .read_rows
.done_rows:
    call clear_buffer    ; очистка буфера после ввода 12 чисел

    ; Ввод 3 чисел для 4-го столбца (индексы 0..2 строк, столбец 3)
    push prompt_input_cols
    call [printf]

    push 0            ; fflush(stdout)
    call [fflush]

    mov ecx, 0
.read_cols:
    cmp ecx, 3
    jge .done_cols

    mov eax, ecx
    shl eax, 4          ; ecx * 16 (row * 4 cols * 4 bytes)
    add eax, 12         ; +3*4 байт смещения по столбцу 3

    lea edx, [array]
    add edx, eax

    push edx
    push fmt_scanf
    call [scanf]
    add esp, 8

    inc ecx
    jmp .read_cols
.done_cols:

    ; Меняем местами array[1,2] и array[1,3]
    mov eax, [array + 24]
    mov ebx, [array + 28]
    mov [array + 24], ebx
    mov [array + 28], eax

    ; Подсчет суммы положительных и количества отрицательных
    xor ecx, ecx
    xor edi, edi
    xor esi, esi

.loop:
    cmp ecx, 12
    jge .calc_done

    mov eax, [array + ecx*4]
    cmp eax, 0
    jg .add_sum
    jl .inc_neg
    jmp .next

.add_sum:
    add edi, eax
    jmp .next

.inc_neg:
    inc esi

.next:
    inc ecx
    jmp .loop

.calc_done:
    mov [sum], edi
    mov [neg_count], esi

    ; Вывод заголовка и массива
    push fmt_title
    call [printf]
    call print_array

    ; Вывод суммы положительных
    push [sum]
    push fmt_sum
    call [printf]
    add esp, 8

    ; Вывод количества отрицательных
    push [neg_count]
    push fmt_neg
    call [printf]
    add esp, 8

    ; Очистка буфера ввода
    call clear_buffer

    ; Сообщение и ожидание клавиши
    push msg_wait
    call [printf]
    call [getchar]

    invoke ExitProcess, 0


print_array:
    push ebp
    mov ebp, esp

    xor ecx, ecx
.print_loop:
    cmp ecx, 12
    jge .print_end

    push dword [array + ecx*4]
    push fmt_int
    call [printf]
    add esp, 8

    inc ecx
    mov eax, ecx
    mov edx, 0
    mov ebx, 4
    div ebx
    cmp edx, 0
    jne .print_loop

    push fmt_line
    call [printf]
    jmp .print_loop

.print_end:
    mov esp, ebp
    pop ebp
    ret

clear_buffer:
    call [getchar]
    cmp al, 10
    jne clear_buffer
    ret

section '.idata' import data readable
library kernel32,'kernel32.dll',\
        msvcrt,'msvcrt.dll'

import kernel32,\
       ExitProcess,'ExitProcess'

import msvcrt,\
       printf,'printf',\
       getchar,'getchar',\
       scanf,'scanf',\
       fflush,'fflush'
