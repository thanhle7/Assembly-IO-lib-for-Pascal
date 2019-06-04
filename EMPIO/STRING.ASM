
Data    segment byte public

Data    ends

Code    segment byte public
        assume  cs:code,ds:data

        public  Upchar
        public  Lochar
        public  UpString
        public  LoString
        public  Replicate
        public  Fill_mem
        public  Trim
        public  RTrim
        public  LTrim
        public  Right
        public  Left
        public  Subs

Replicate       proc far
;Function Replicate(AAA : char;Repl_num:byte) : string;
        push    bp
        mov     bp,sp
        mov     cl,byte ptr ss:[bp+6]
        xor     ch,ch
        mov     al,byte ptr ss:[bp+8]
        les     di,dword ptr ss:[bp+10]
        mov     byte ptr es:[di],cl
        inc     di
        cld
        rep     stosb
        pop     bp
        retf    4
Replicate       endp

Fill_mem        proc    far
;Procedure Fill_mem(ZZZ : pointer ; AAA : char ; Fill_num : integer);
        push    bp
        mov     bp,sp
        mov     cx,word ptr ss:[bp+6]
        mov     al,byte ptr ss:[bp+8]
        les     di,dword ptr ss:[bp+10]
        mov     byte ptr es:[di],cl
        inc     di
        cld
        rep     stosb
        pop     bp
        retf    8
Fill_mem        endp

Trim    proc    far
        push    bp
        mov     bp,sp
        push    ds
        les     di,dword ptr ss:[bp+ 6]
        mov     bl,byte ptr es:[di]
        xor     bh,bh
        or      bx,bx
        jz      Trim_2
Trim_0:
        cmp     byte ptr es:[di+bx],' '
        je      Trim_1
        cmp     byte ptr es:[di+bx],0
        jne     Trim_2
Trim_1:
        dec     bx
        jnz     Trim_0
Trim_2:
        mov     cx,bx
        jmp     Ltrim_begin
Trim    endp

RTrim   proc    far
;Function RTrim(var ZZZ) : string;
        push    bp
        mov     bp,sp
        push    ds
        lds     si,dword ptr ss:[bp+ 6]
        les     di,dword ptr ss:[bp+10]
        push    di
        mov     cl,byte ptr ds:[si]
        xor     ch,ch
        push    cx
        inc     cx
        cld
        rep     movsb
        pop     cx
        dec     di
        jcxz    RTrim_2
RTrim_0:
        cmp     byte ptr es:[di],' '
        je      RTrim_1
        cmp     byte ptr es:[di],0
        je      RTrim_1
        jne     RTrim_2
RTrim_1:
        dec     di
        loop    RTrim_0
RTrim_2:
        pop     di
        mov     byte ptr es:[di],cl
        pop     ds
        pop     bp
        retf    4
RTrim   endp

LTrim   proc    far
;Function LTrim(var ZZZ) : string;
        push    bp
        mov     bp,sp
        push    ds
        les     di,dword ptr ss:[bp+6]
        mov     cl,byte ptr es:[di]
        xor     ch,ch
LTrim_begin:
        inc     di
        jcxz    Ltrim_2
LTrim_0:
        cmp     byte ptr es:[di],' '
        je      LTrim_1
        cmp     byte ptr es:[di],0
        je      LTrim_1
        jne     LTrim_2
LTrim_1:
        inc     di
        loop    LTrim_0
LTrim_2:
        lds     si,dword ptr ss:[bp+6]
        mov     si,di
        les     di,dword ptr ss:[bp+10]
        mov     byte ptr es:[di],cl
        inc     di
        cld
        rep     movsb
        pop     ds
        pop     bp
        retf    4
LTrim   endp

Left    proc    far
;Function Left(var Str_var;L_num:byte):string;
        push    bp
        mov     bp,sp
        push    ds
        lds     si,dword ptr ss:[bp+ 8]
        les     di,dword ptr ss:[bp+12]
        mov     cl,byte ptr ds:[si]
        mov     dl,byte ptr ss:[bp+ 6]
        cmp     dl,cl
        ja      Left_1
        mov     cl,dl
Left_1:
        mov     byte ptr es:[di],cl
        xor     ch,ch
        inc     si
        inc     di
        cld
        rep     movsb
        pop     ds
        pop     bp
        retf    6
Left    endp

Right   proc    far
;Function Right(var Str_var;L_num:byte):string;
        push    bp
        mov     bp,sp
        push    ds
        mov     dl,byte ptr ss:[bp+ 6]
        xor     dh,dh
        lds     si,dword ptr ss:[bp+ 8]
        les     di,dword ptr ss:[bp+12]
        mov     cl,byte ptr ds:[si]
        xor     ch,ch
        cmp     dl,cl
        ja      Right_1
        sub     cl,dl
        add     si,cx
        mov     cx,dx
Right_1:
        mov     byte ptr es:[di],cl
        inc     si
        inc     di
        cld
        rep     movsb
        pop     ds
        pop     bp
        retf    6
Right   endp

Subs    proc    far
;Function Substring(var Str_var;Begin_pos,Str_size:byte):string;
        push    bp
        mov     bp,sp
        push    ds
        mov     dh,byte ptr ss:[bp+ 8]          ; Begin_pos
        mov     dl,byte ptr ss:[bp+ 6]          ; Sub_Str_size
        lds     si,dword ptr ss:[bp+10]
        les     di,dword ptr ss:[bp+14]
        mov     byte ptr es:[di],0
        or      dl,dl
        jz      Subs_end
        or      dh,dh
        jz      Subs_end
        mov     cl,byte ptr ds:[si]
        xor     ch,ch
        jcxz    Subs_end
        cmp     dh,cl
        ja      Subs_end
        mov     ax,dx
        add     al,ah
        dec     al
        cmp     al,cl
        jbe     Subs_1
        sub     al,cl                           ; AL = so du
        sub     dl,al                           ; Giam Sub_Str_size
Subs_1:
        mov     cl,dl
        xchg    dh,dl
        xor     dh,dh
        add     si,dx
        mov     byte ptr es:[di],cl
        inc     di
        cld
        rep     movsb
Subs_end:
        pop     ds
        pop     bp
        retf    8
Subs    endp


Up_char proc    near
        ;AL = char
        cmp     al,'a'
        jb      UC_end
        cmp     al,'z'
        ja      UC_end
        sub     al,'a'-'A'
UC_end:
        ret
Up_char endp

Lo_char proc    near
        ;AL = char
        cmp     al,'A'
        jb      Lo_end
        cmp     al,'Z'
        ja      Lo_end
        add     al,'a'-'A'
Lo_end:
        ret
Lo_char endp

UpChar  proc    far
;Function Upchar(a:char):char
        push    bp
        mov     bp,sp
        mov     al,byte ptr ss:[bp+6]
        call    Up_char
        pop     bp
        retf    2
UpChar  endp

LoChar  proc    far
;Function Lochar(a:char):char
        push    bp
        mov     bp,sp
        mov     al,byte ptr ss:[bp+6]
        call    Lo_char
        pop     bp
        retf    2
LoChar  endp

UpString proc    far
;Function UpString(a:string):string
        push    bp
        mov     bp,sp
        push    ds
        lds     si,dword ptr ss:[bp+ 6]
        les     di,dword ptr ss:[bp+10]
        mov     cl,byte ptr ds:[si]
        xor     ch,ch
        mov     byte ptr es:[di],cl
        jcxz    Up_str_end
        inc     si
        inc     di
Up_str_1:
        cld
        lodsb
        call    Up_char
        stosb
        loop    Up_Str_1

Up_Str_end:
        pop     ds
        pop     bp
        retf    4
UpString  endp

LoString proc    far
;Function LoString(a:string):string
        push    bp
        mov     bp,sp
        push    ds
        lds     si,dword ptr ss:[bp+ 6]
        les     di,dword ptr ss:[bp+10]
        mov     cl,byte ptr ds:[si]
        xor     ch,ch
        mov     byte ptr es:[di],cl
        jcxz    Lo_str_end
        inc     si
        inc     di
Lo_str_1:
        cld
        lodsb
        call    Lo_char
        stosb
        loop    Lo_Str_1

Lo_Str_end:
        pop     ds
        pop     bp
        retf    4
LoString  endp


code    ends
        end
