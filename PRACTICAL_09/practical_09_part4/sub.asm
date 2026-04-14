global sub

section .text

sub:
    mov eax, [esp+4]     ; arg1 (a)
    sub eax, [esp+8]     ; arg2 (b)
    ret