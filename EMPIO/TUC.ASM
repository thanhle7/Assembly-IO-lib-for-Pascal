code    segment
        assume cs: code, ds: code
        jmp     main
excstr  db      'Command line: '
chuoi   db      100 dup (0)

main    proc    near
        push    es

        mov     ah, 062h
        int     021h
        mov     es, bx                          ; PSP segment
        mov     ax, word ptr ES:[02Ch]
        mov     es, ax
        xor     di, di
        mov     al, 0
m1:
        cld
        mov     cx, 0FFFFh
        Repne   scasb
        or      byte ptr es:[di], 0
        jne     m1

        add     di, 3
        lea     si, chuoi
m01:
        mov     al, byte ptr es:[di]
        or      al, al
        jz      m2
        mov     byte ptr ds:[si], al
        inc     si
        inc     di
        jmp     m01
m2:
        mov     byte ptr ds:[si], '$'
        lea     dx, Excstr
        mov     ah, 09
        int     021h

        pop     es
        int     020h
main    endp
code    ends
