True_value      equ     1
False_value     equ     0

Cur_up          equ  04800h
Cur_down        equ  05000h
Cur_left        equ  04B00h
Cur_right       equ  04D00h
ESC_key         equ  0011Bh
Tab_key         equ  00F09h
Shift_Tab       equ  00F00h
Enter_key       equ  01C0Dh
Ins_key         equ  05200h
Del_key         equ  05300h
Backspace       equ  00E08h
Home_key        equ  04700h
End_key         equ  04F00h

ele_type        equ  0     ;        word;
ele_addr        equ  2     ;        dword
ele_offset      equ  2     ;        word;
ele_segment     equ  4     ;        word;
ele_size        equ  6     ;        byte;
ele_dec         equ  7     ;        byte;
ele_col         equ  8     ;        byte;
ele_row         equ  9     ;        byte;
Check_proc      equ  10    ;        dword
Sub_proc        equ  14    ;        dword

Get_size        equ  18

Data    segment public
        EXTRN EMP_VNI_KEY  : byte
        EXTRN get_count    : word
        EXTRN get_point    : word
        EXTRN Last_pos     : word
        EXTRN get_pos      : byte
        EXTRN get_color    : BYTE
        EXTRN get_confirm  : BYTE
        EXTRN GS_check     : BYTE
        EXTRN get_mode     : byte
        EXTRN str_get      : byte
        EXTRN GetBuffer    : byte
        EXTRN Cur_para     : byte
        EXTRN Exit_key     : word

        EXTRN Col          : byte
        EXTRN Row          : byte

        EXTRN Date_value    : word
        EXTRN Real_value    : word
        EXTRN Error_make_num: word

        EXTRN Decpos       : byte
        EXTRN Ins_flag     : byte
        EXTRN Edit_flag    : byte

        EXTRN Date_separate : byte
        EXTRN Date_type     : byte

        Pass_end        db      0
        Cur_point       dw      0
Data    ends

Code    segment byte public
        assume  cs:Code, ds:Data

        Public Readg,disp_get,getc,gets,geti,getl,getr,getd,pict,valid,Subproc
        Public Get_Str, EMP_VNI_load, EMP_VNI_Unload

        Extrn Make_integer_str : far
        Extrn Make_longint_str : far
        Extrn Make_real_str    : far

        Extrn Make_integer_num : far
        Extrn Make_longint_num : far
        Extrn Make_real_num    : far

        Extrn WScr             : near
        Extrn Cursor_on        : far
        Extrn Cursor_off       : far

Disp_get        proc    far

        push    bp
        push    ds
        pop     es
        call    Cursor_off
        mov     ax,1
DG0:
        push    ax
        call    take_get_para                   ; Display get_ele
        pop     ax
        inc     ax
        cmp     ax,word ptr get_count
        jbe     DG0
        mov     word ptr decpos,0
        pop     bp
        ret
Disp_get        endp

;-----------------------------------
; EMP_VNI
;-----------------------------------
EMP_VNI Proc    near
        or      byte ptr EMP_VNI_KEY, 0
        je      EVEnd
        cmp     al, '1'
        jb      EVend
        cmp     al, '9'
        ja      Evend

        push    es
        push    bx
        mov     dx, ax
        push    dx

        mov     ax, cs
        mov     es, ax
        mov     ax, word ptr Exit_key           ; Lastkey
        mov     byte ptr es:ChrStop, 0
EV:
        mov     byte ptr es:CharEnd, al
        inc     byte ptr es:ChrStop

        lea     di, CharSet
        sti
        mov     cx, 161                         ; ChrsMap + 1
        repne   scasb
        or      cx, cx
        je      EV1                             ; Not change
        mov     ax, 160                         ; CharSet Number
        sub     ax, cx
        mov     cl, 16                          ; chars of line
        div     cl
        add     al, '0'
        cmp     al, dl
        je      EV1                             ; Not change
        xchg    ax, dx
        sub     al, '0'
        mul     cl
        mov     bx, ax
        mov     al, dh
        xor     ah, ah
        add     bx, ax
        mov     al, byte ptr es:CharSet[bx]

        cmp     al, byte ptr es:CharEnd
        je      EV1                             ; same from origine
        cmp     dl, '0'
        je      EVV
        cmp     byte ptr es:ChrStop, 2
        ja      EVV
        jmp     EV
EVV:
        pop     dx                              ; New char
        mov     dl, al
        pop     bx
        cmp     bl, 1
        je      EV0
        dec     bx
        call    Del_char
EV0:    push    bx
        push    dx
EV1:
        pop     ax
        pop     bx
        pop     es
EVend:
        ret
EMP_VNI Endp
;-----------------------------------

Read_get        proc    near

        mov     ax,word ptr Get_point
        call    take_ele_addr
        cmp     word ptr [si+Sub_proc+2],0      ; Does Check_proc exist ?
        je      GS_begin
        call    dword ptr [si+Sub_proc]         ; Subproc procedure
        call    Disp_get
        mov     ax,Exit_key
        mov     Edit_flag,False_value
        mov     bx,1
        jmp     GS0b
GS_begin:
        call    Cursor_on
        mov     ax,word ptr get_point
        mov     word ptr Cur_point,ax
        call    take_get_para
        mov     Edit_flag,False_value
        cmp     Exit_key,Cur_down
        je      GS_LP
        cmp     Exit_key,Cur_up
        jne     GS_NLP
GS_LP:
        mov     bx,Last_pos
        cmp     byte ptr cur_para[ele_type],5   ; Is Date type ?
        je      GS_NLP                          ; Yes
        cmp     bl,byte ptr cur_para[ele_size]
        jbe     GS0
GS_NLP:
        mov     bx,1
GS0:
        cmp     bl,byte ptr Str_get
        jbe     GS0a
        mov     bl,byte ptr Str_get
        cmp     Get_confirm,True_value
        je      GS0a
        cmp     byte ptr cur_para[ele_type],1
        jbe     GS0@
        cmp     Error_make_num,0                ; Num_string OK ?
        jnz     GS00                            ; Error !
GS0@:
        call    W_str_get                       ; Display string_get
        mov     ax,Enter_key                    ; Go to next get_element
        jmp     GS0b
GS0a:
        cmp     byte ptr cur_para[ele_type],4   ; Is get_variable real type ?
        jne     GS00
        cmp     bl,byte ptr decpos              ; Is cursor position duplicate
        jne     GS00                            ;    with dec_pos ?
        inc     bx
GS00:
        call    W_str_get                       ; Display string_get
        xor     ax,ax
        mov     word ptr Error_make_num,ax
        push    bx
        int     016h                            ; Read keyboard
        pop     bx

        call    EMP_VNI                         ; Set EMP_VNI font

GS0b:
        mov     Exit_key,ax                     ; Store inkey to Exit_key
        mov     Last_pos,bx

        cmp     ax,home_key
        jne     GS01
        mov     bx,1
        jmp     GS0
GS01:
        cmp     ax,end_key
        jne     GS02
        mov     bl,byte ptr str_get
        jmp     GS0
GS02:
        cmp     ax,Tab_key                      ; Tab_key will move cursor
        jne     GS03                            ;  to next word in get string
GS02a:
        cmp     bl,byte ptr str_get
        je      GS0
        cmp     byte ptr str_get[bx],' '        ; Searching next first blank
        je      GS02b
        inc     bl
        jmp     GS02a
GS02b:
        cmp     byte ptr str_get[bx],' '        ; Searching next first
        jne     GS0                             ;                non-blank
        inc     bl
        cmp     bl,byte ptr str_get
        jne     GS02b
        jmp     GS0
GS03:
        cmp     ax,Shift_Tab                    ; Shift Tab_key will move cursor
        jne     GS04                            ;  to last word in get string
GS03a:
        cmp     bl,1
        je      GS05                            ; Searching last first
        dec     bl                              ;                non-blank
        cmp     byte ptr str_get[bx],' '
        je      GS03a
GS03b:
        dec     bl
        cmp     bl,1
        je      GS05
        cmp     byte ptr str_get[bx],' '        ; Searching last first blank
        jne     GS03b
        inc     bl
        jmp     GS05
GS04:
        cmp     ax,cur_left
        jne     GS1
        cmp     bl,1
        je      GS05
        dec     bl
        mov     cx,-1
        call    Make_Date_pos
        cmp     bl,byte ptr decpos
        jne     GS05
        cmp     bl,1
        je      GS05
        dec     bl
GS05:
        jmp     GS0
GS1:
        cmp     ax,cur_right
        jne     GS2
        cmp     bl,byte ptr Str_get
        je      GS11
        inc     bl
        mov     cx,1
        call    Make_Date_pos
        cmp     bl,byte ptr decpos
        jne     GS11
        cmp     bl,byte ptr str_get
        jae     GS11
        inc     bl
GS11:
        jmp     GS0
GS2:
        cmp     ax,Backspace
        jne     GS3
        cmp     bl,1
        je      GS11
        dec     bl
        mov     cx,-1
        call    Make_Date_pos
        cmp     bl,byte ptr decpos
        jne     GS21
        cmp     bl,1
        je      GS11
        dec     bl
        jmp     GS0
GS21:
        call    del_char
        jmp     GS0
GS3:
        cmp     ax,Del_key
        jne     GS4
        call    del_char
        jmp     GS0
GS4:
        cmp     ax,Ins_key
        jne     GS5
        not     byte ptr Ins_flag
        jmp     GS0
GS5:
        cmp     ax,ESC_key
        je      GS9
        cmp     ax,Enter_key
        je      GS9
        or      al,al
        jz      GS9
        cmp     al,10
        je      GS8
        call    Check_key
        jc      GS8

        cmp     byte ptr cur_para[ele_type],1
        jbe     GS52
        cmp     al,'.'
        jne     GS51
        cmp     byte ptr cur_para[ele_type],4
        jne     GS11
        cmp     byte ptr cur_para[ele_dec],0
        je      GS11
        call    remake_num
        jmp     GS0
GS51:
        cmp     byte ptr cur_para[ele_type],4
        je      GS6
GS52:
        cmp     byte ptr Ins_flag,0
        je      GS6
        push    ds
        pop     es
        mov     cl,byte ptr str_get
        xor     ch,ch
        lea     si,str_get
        add     si,cx
        mov     di,si
        dec     si
        sub     cx,bx
        jz      GS6
        std
        rep     movsb
GS6:
        mov     byte ptr str_get[bx],al
        mov     Edit_flag,True_value
GS7:
        inc     bx
        mov     cx,1
        call    Make_Date_pos
GS71:
        mov     byte ptr pass_end,0
        cmp     bl,byte ptr str_get
        jbe     GS8
        mov     byte ptr pass_end,0FFh
GS8:
        jmp     GS0
GS9:
        cmp     ax,ESC_key
        jne     GS90
        mov     ax,word ptr get_point
        call    Take_get_para
        call    w_str_get
        jmp     GS97
GS90:
        cmp     byte ptr cur_para[ele_type],1
        jbe     GS93
        cmp     ax,Enter_key
        je      GS91
        call    remake_pos
GS91:
        cmp     Edit_flag,True_value
        jne     GS93
        cmp     byte ptr cur_para[ele_type],5
        jne     GS92
        push    ds
        pop     es
        lea     si,str_get
        lea     di,Date_value
        mov     word ptr Error_make_num,0
        push    bx
        call    Make_Date_value
        pop     bx
        jnc     GS922
        mov     word ptr Error_make_num,bx
        jmp     GS71
GS92:
        call    remake_num
        call    W_str_get
        call    Make_num
GS921:
        mov     bx,word ptr Error_make_num
        cmp     bx,0
        jne     GS71                            ; Invalid num_format
        call    Make_num_str
GS922:
        call    W_str_get
GS93:
        cmp     Exit_key,ESC_key                ;        get_variable
        je      GS98
        mov     ax,word ptr Cur_point
        call    Take_ele_addr
        cmp     word ptr [si+Check_proc+2],0    ; Does Check_proc exist ?
        je      GS98
        push    es
        call    dword ptr [si+Check_proc]       ; Boolean function
        pop     es
        or      al,al                           ; False --> AL = 0
        jnz     GS98
        mov     ax,word ptr Cur_point           ; Retry
        mov     word ptr Get_point,ax
        jmp     Read_get
GS98:
        mov     ax,Exit_key
        cmp     ax,Enter_key
        je      GS95
        cmp     ax,cur_up
        jne     GS94
        cmp     byte ptr get_point,0
        je      GS96
        dec     byte ptr get_point
        jmp     GS96
GS94:
        cmp     ax,cur_down
        jne     GS96
GS95:
        inc     byte ptr get_point
GS96:
        cmp     Edit_flag,True_value
        jne     GS97
        call    Assign_para                     ; Assign new value to
GS97:
        call    Cursor_off
        ret

Read_get        endp

Readg           proc    far

        push    bp
        push    ds
        pop     es
        cmp     Get_mode,0
        jne     RG_0
        mov     Get_point,1
RG_0:
        mov     Last_pos,-1
        call    Disp_get
RG_1:
        call    Read_get
        mov     ax,Exit_key
        cmp     ax,Enter_key
        je      RG_2
        cmp     ax,cur_up
        je      RG_2
        cmp     ax,cur_down
        jne     RG_3
RG_2:
        mov     ax,Get_count
        cmp     Get_point,ax
        ja      RG_4
        cmp     Get_point,0
        ja      RG_1
        je      RG_4
RG_3:
        cmp     ax,cur_left
        je      RG_1
        cmp     ax,cur_right
        je      RG_1
RG_4:
        call    Disp_get
        mov     Get_Count,0
        cmp     Get_mode,0
        jne     RG_5
        mov     Get_Point,0
RG_5:
        pop     bp
        ret

Readg           endp

Make_Date_pos   proc    near
; CX = 1 --> right ; CX = -1 --> left
; BX = get_pos
        cmp     byte ptr cur_para[ele_type],5
        jne     MDP_end
        cmp     bx,3
        je      MDP_1
        cmp     bx,6
        jne     MDP_end
MDP_1:
        add     bx,cx
MDP_end:
        ret
Make_Date_Pos   endp

Check_key   proc    near
        ; AL = Num_key
        ;
        mov     ah,byte ptr cur_para[ele_Type]
        cmp     ah,1
        jbe     CK_OK
        cmp     ah,4
        je      CK_1
        cmp     ah,5
        je      CK_3
        jne     CK_2
CK_1:
        cmp     al,'.'
        je      CK_OK
CK_2:
        cmp     al,'+'
        je      CK_OK
        cmp     al,'-'
        je      CK_OK
CK_3:
        cmp     ah,5
        jne     CK_6
        cmp     al,'?'
        je      CK_OK
CK_6:
        cmp     al,'0'
        jb      CK_error
        cmp     al,'9'
        jbe     CK_OK
CK_error:
        stc
        ret
CK_OK:
        clc
        ret
Check_key   endp

Del_char        proc    near
        push    ds
        pop     es
        push    bx
        lea     di,str_get
        add     di,bx
        mov     si,di
        inc     si
        mov     cl,byte ptr str_get
        xor     ch,ch
        cmp     byte ptr cur_para[ele_type],5   ; Date_type
        jne     DC0
        cmp     bl,7
        jae     DC1
        mov     cl,2
        cmp     bl,cl
        jbe     DC1
        mov     cl,5
        jmp     DC1
DC0:
        cmp     byte ptr cur_para[ele_type],4   ; Real_type
        jne     DC1
        cmp     bl,byte ptr decpos
        jae     DC1
        mov     cl,byte ptr decpos
        dec     cl
DC1:
        push    cx
        sub     cx,bx
        cld
        rep     movsb
        pop     bx
        mov     byte ptr str_get[bx],' '
        pop     bx
        mov     Edit_flag,True_value
        ret

Del_char        endp

Remake_num     proc    near
        push    ds
        pop     es
        cmp     bx,word ptr decpos
        jae     RMN1
        cmp     byte ptr pass_end,0FFh
        je      RMN1
        lea     si,str_get
        mov     di,si
        add     si,bx
        dec     si
        add     di,word ptr decpos
        dec     di
        std
        mov     cx,bx
        dec     cx
        rep     movsb
        mov     cx,word ptr decpos
        sub     cx,bx
        lea     di,str_get+1
        cld
        mov     al,' '
        jcxz    RMN1
        rep     stosb
        cmp     byte ptr cur_para[ele_type],4
        jne     RMN1
        cmp     byte ptr cur_para[ele_dec],0
        je      RMN1
        mov     bx,word ptr decpos
        inc     bx

        lea     di,str_get
        add     di,bx
        mov     cl,byte ptr cur_para[ele_dec]
        mov     al,'0'
        rep     stosb
RMN1:
        ret

Remake_num      endp

Remake_pos      proc    near
        push    ds
        pop     es
        lea     di,str_get
        mov     bl,byte ptr str_get
        xor     bh,bh
        add     di,bx
        std
        mov     cx,bx
        mov     al,' '
        repe    scasb
        mov     bx,cx
        inc     bx
        inc     bx
        ret
Remake_pos      endp

Make_num        proc    near
        push    bx
        mov     bx,word ptr cur_para[ele_type]
        cmp     bx,2
        jne     MN1
        call    Make_integer_num
        jmp     MN3
MN1:
        cmp     bx,3
        jne     MN2
        call    Make_longint_num
        jmp     MN3
MN2:
        cmp     bx,4
        jne     MN3
        call    Make_real_num
MN3:
        pop     bx
        ret
Make_num        endp

Make_num_str    proc    near
        push    bx
        mov     bx,word ptr cur_para[ele_type]
        cmp     bx,2
        jne     MNS1
        call    Make_integer_str
        jmp     MNS3
MNS1:
        cmp     bx,3
        jne     MNS2
        call    Make_longint_str
        jmp     MNS3
MNS2:
        cmp     bx,4
        jne     MNS3
        call    Make_real_str
MNS3:
        pop     bx
        ret
Make_num_str    endp


Make_get_c      proc    near
        push    ds
        mov     cl,byte ptr cur_para[ele_size]
        mov     byte ptr str_get,cl
        lds     si,dword ptr cur_para[ele_addr]
        lea     di,str_get+1
MGCS:
        xor     ch,ch
        cld
        rep     movsb
        pop     ds
        lea     si,str_get
        mov     cl,byte ptr [si]
        xor     ch,ch
MC1:
        inc     si
        cmp     byte ptr [si],0
        jne     MC2
        mov     byte ptr [si],' '
MC2:
        loop    MC1
        ret
Make_get_c      endp

Make_get_s      proc    near
        push    ds
        lds     si,dword ptr cur_para[ele_addr]
        mov     cl,byte ptr [si]
        or      cl,cl
        jnz     MS1                     ; NUL string ?
        pop     ds
        lea     di,str_get
        cld
        mov     cl,byte ptr cur_para[ele_size]
        xor     ch,ch
        mov     al,cl
        stosb
        inc     cl
        mov     al,' '
        rep     stosb
        mov     Edit_flag,True_value
        ret
MS1:
        lea     di,str_get
        mov     byte ptr es:cur_para[ele_size],cl
        inc     cl
        mov     byte ptr es:decpos,cl
        jmp     MGCS
Make_get_s      endp

Make_get_num    proc    near
        push    ds
        lea     di,Real_value
        lds     si,dword ptr cur_para[ele_addr]
        mov     cx,3
        cld
        rep     movsw
        pop     ds
        mov     al,byte ptr cur_para[ele_size]
        mov     byte ptr str_get,al
        call    Make_num_str
        ret
Make_get_num    endp

Make_Get_Date   proc    near
        push    ds
        lea     di,Date_value
        lds     si,dword ptr cur_para[ele_addr]
        mov     cx,4
        cld
        rep     movsw
        pop     ds
        lea     si,Date_value
        lea     di,str_get
        call    Make_Date_Str
        mov     cl,byte ptr str_get
        mov     byte ptr cur_para[ele_size],cl
        mov     word ptr Decpos,0
        ret
Make_Get_Date   endp

Take_get_para   proc   near

        push    ds
        pop     es
        call    Take_ele_addr
        lea     di,cur_para
        mov     cx,Get_size
        cld
        rep     movsb
        mov     bl,byte ptr cur_para[ele_size]
        inc     bl
        cmp     byte ptr cur_para[ele_type],4
        jne     TG1
        cmp     byte ptr cur_para[ele_dec],0
        je      TG1
        sub     bl,byte ptr cur_para[ele_dec]
        dec     bl
TG1:
        xor     bh,bh
        mov     word ptr decpos,bx
        mov     bx,word ptr cur_para[ele_type]
        shl     bx,1
        call    word ptr cs:Make_get[bx]
        call    W_str_get
        ret

Take_get_para   endp
Make_get   dw      offset make_get_c
           dw      offset make_get_s
           dw      offset make_get_num
           dw      offset make_get_num
           dw      offset make_get_num
           dw      offset Make_Get_Date

Assign_para     proc    near
        push    es
        xor     ch,ch
        mov     bx,word ptr cur_para[ele_type]
        cmp     bl,1
        ja      As_num
As_chuoi:
        lea     si,str_get
        mov     cl,byte ptr [si]
        inc     si
        or      bl,bl
        jz      AS_c
        dec     si
        inc     cl
As_c:
        jmp     AP_end
As_num:
        lea     si,Real_value                   ; Date_value
        mov     cx,8
        cmp     bx,5
        je      AP_end
        dec     bl
        shl     bl,1
        mov     cx,bx
AP_end:
        les     di,dword ptr cur_para[ele_addr]
        cld
        rep     movsb
        pop     es
        ret
Assign_para     endp

Take_ele_addr   proc   near
        push    cx
        lea     si,Getbuffer
        dec     al
        mov     cl,Get_size
        mul     cl
        add     si,ax
        pop     cx
        ret
Take_ele_addr   endp

getc    proc    far
        mov     cx,0
        jmp     get
Getc    endp

gets    proc    far
        mov     cx,1
        jmp     get
Gets    endp

geti    proc    far
        mov     cx,2
        jmp     get
Geti    endp

getl    proc    far
        mov     cx,3
        jmp     get
Getl    endp

getr    proc    far
        mov     cx,4
        jmp     get
Getr    endp

getd    proc    far
        mov     cx,5
        jmp     get
Getd    endp

Get     proc    near

        push    ds
        pop     es
        push    bp
        mov     bp,sp
        inc     word ptr Get_count
        mov     ax,word ptr get_count
        call    Take_ele_addr

        mov     ax,word ptr ss:[bp+6]
        mov     word ptr [si+ele_offset],ax
        mov     ax,word ptr ss:[bp+8]
        mov     word ptr [si+ele_segment],ax

        mov     ah,byte ptr row
        mov     al,byte ptr col
        mov     word ptr [si+ele_col],ax

        mov     word ptr [si+ele_type],cx
        mov     byte ptr [si+ele_size],6
        mov     byte ptr [si+ele_dec ],0
        xor     ax,ax
        mov     word ptr [si+Check_proc+0],ax
        mov     word ptr [si+Check_proc+2],ax
        mov     word ptr [si+Sub_proc+0],ax
        mov     word ptr [si+Sub_proc+2],ax
        pop     bp
        retf    4
get     endp

Pict    proc    far
        push    bp
        mov     bp,sp
        mov     ax,word ptr get_count
        call    Take_ele_addr
        mov     ax,word ptr ss:[bp+8]
        mov     byte ptr [si+ele_size],al
        mov     ax,word ptr ss:[bp+6]
        mov     byte ptr [si+ele_dec],al
        pop     bp
        retf    4
Pict    endp

Valid   proc    far
        push    bp
        mov     bp,sp
        mov     ax,word ptr get_count
        call    Take_ele_addr
        les     bx,dword ptr ss:[bp+6]
        mov     word ptr [si+Check_proc+0],bx
        mov     word ptr [si+Check_proc+2],es
        pop     bp
        retf    4
Valid   endp

SubProc proc    far
        push    bp
        mov     bp,sp
        mov     ax,word ptr get_count
        call    Take_ele_addr
        les     bx,dword ptr ss:[bp+6]
        mov     word ptr [si+Sub_proc+0],bx
        mov     word ptr [si+Sub_proc+2],es
        pop     bp
        retf    4
SubProc endp

W_str_get       proc    near
        push    bx
        mov     ah,byte ptr get_color
        mov     dx,word ptr Cur_para[ele_col]
        mov     cl,byte ptr str_get
        xor     ch,ch
        lea     si,str_get+1
        call    WScr
        mov     dx,word ptr Cur_para[ele_col]
        pop     bx
        push    bx
        add     dl,bl
        dec     dl
        mov     ah,02
        xor     bh,bh
        int     010h
        mov     ah,03                   ; get cursor size
        int     010h
        cmp     byte ptr Ins_flag,0
        je      WSG1
        mov     ch,02                   ; Insert
        jne     WSG2
WSG1:
        mov     ch,cl                   ; Replace
        or      ch,ch
        jz      WSG3
        dec     ch
WSG2:
        mov     ah,01                   ; set cursor size
        int     010h
WSG3:
        pop     bx
        ret
W_str_get       endp


Get_str proc    far
;       procedure get_str(var chuoi);

        push    bp
        push    ds
        pop     es
        call    cursor_on
        lea     di,Str_get
        mov     bp,sp
        lds     si,dword ptr ss:[bp+6]
        mov     cl,byte ptr ds:[si]
        inc     cl
        mov     es:Decpos,cl
        xor     ch,ch
        cld
        rep     movsb
        push    es
        pop     ds
        mov     al,Row
        mov     Cur_para[ele_row],al
        mov     al,Col
        mov     Cur_para[ele_col],al
        mov     Edit_flag,False_value
        xor     bx,bx
        mov     bl,Get_pos
        cmp     bl,byte ptr Str_get[0]
        jbe     GSTR_2
End_cur:
        mov     bl,byte ptr Str_get[0]
GSTR_0:
        or      bx,bx
        jz      GSTR_1
        cmp     byte ptr Str_get[bx],20h
        jne     GSTR_1
        dec     bx
        jmp     GSTR_0
GSTR_1:
        cmp     byte ptr Str_get[bx],0h
        jne     GSTR_11
        dec     bx
        jmp     GSTR_0
GSTR_11:
        cmp     bl,byte ptr Str_get[0]
        je      GSTR_2
        inc     bx
GSTR_2:
        call    W_str_get
        cmp     Edit_flag,True_value
        jne     GSTR_21
        cmp     GS_Check,True_value
        jne     GSTR_21
        jmp     GSTR_9
GSTR_21:
        xor     ax,ax
        push    bx
        int     016h

        mov     Exit_key,ax
        pop     bx

        cmp     ax,Cur_left
        jne     GSTR_3
        cmp     bx,1
        je      GSTR_2
        dec     bx
        jmp     GSTR_2
GSTR_3:
        cmp     ax,Cur_right
        jne     GSTR_4
GSTR_31:
        cmp     bl,byte ptr Str_get[0]
        je      GSTR_2
        inc     bx
        jmp     GSTR_2
GSTR_4:
        cmp     ax,Home_key
        jne     GSTR_5
        mov     bx,1
        jmp     GSTR_2
GSTR_5:
        cmp     ax,End_key
        je      end_cur

        cmp     ax,Backspace
        jne     GSTR_6
        cmp     bx,1
        je      GSTR_21
        dec     bx
GSTR_51:
        call    Del_char
        jmp     GSTR_2
GSTR_6:
        cmp     ax,Del_key
        jne     GSTR_7
        call    Del_char
        jmp     GSTR_2
GSTR_7:
        cmp     ax,Ins_key
        jne     GSTR_8
        not     Ins_flag
GSTR_71:
        jmp     GSTR_2
GSTR_8:
        or      al,al
        jz      GSTR_9
        cmp     ax,Enter_key
        je      GSTR_9
        cmp     ax,ESC_key
        je      GSTR_9
        cmp     al,0
        je      GSTR_71

        cmp     Ins_flag,0
        je      GSTR_85
        push    bx
GSTR_81:
        mov     ah,byte ptr Str_get[bx]
        mov     byte ptr Str_get[bx],al
        cmp     bx,di
        je      GSTR_82
        inc     bx
        mov     al,ah
        jmp     GSTR_81
GSTR_82:
        pop     bx
        jmp     GSTR_86
GSTR_85:
        mov     byte ptr Str_get[bx],al
GSTR_86:
        mov     Edit_flag,True_value
        jmp     GSTR_31
GSTR_9:
        mov     Get_pos,bl
        les     di,dword ptr ss:[bp+6]
        lea     si,Str_get
        mov     cl,byte ptr Str_get
        xor     ch,ch
        inc     cx
        cld
        rep     movsb
        call    cursor_off
        pop     bp
        retf    4

Get_str endp

;---- Date function ----------------------
;
; Date format YYYYMMDD  eg 19910815
;
;-----------------------------------------

Public Dtoc,Day,Month,Year

_Atoi   proc    near
; DS:SI = @num_str
; CX    = Str_len
        push    bx
        push    cx
        push    dx
        push    si
        push    bp
        xor     bp,bp
        mov     bx,10
        jcxz    Atoi2
Atoi1:
        cld
        lodsb
        cmp     al,' '
        jne     Atoi1a
        mov     al,'0'
Atoi1a:
        sub     al,'0'
        xor     ah,ah
        xchg    ax,bp
        mul     bx
        add     bp,ax
        loop    Atoi1
Atoi2:
        mov     ax,bp
        pop     bp
        pop     si
        pop     dx
        pop     cx
        pop     bx
        ret
_Atoi   endp

_Day    proc    near
; DS:SI = @Date_value
        push    si
        mov     cx,2
        add     si,6
        call    _Atoi
        pop     si
        ret
_Day    endp

_Month  proc    near
; DS:SI = @date_value
        push    si
        mov     cx,2
        add     si,4
        call    _Atoi
        pop     si
        ret
_Month  endp

_Year   proc    near
; DS:SI = @date_value
        mov     cx,4
        call    _Atoi
        ret
_Year   endp

;-------------------------------------------------------------------------------
;Function Day(var date_var:date):integer
;-------------------------------------------------------------------------------
Day     proc    far
        push    bp
        mov     bp,sp
        push    ds
        lds     si,dword ptr ss:[bp+6]
        call    _Day
        pop     bp
        retf    4
Day     endp

;-------------------------------------------------------------------------------
;Function Month(var date_var:date):integer
;-------------------------------------------------------------------------------
Month   proc    far
        push    bp
        mov     bp,sp
        push    ds
        lds     si,dword ptr ss:[bp+6]
        call    _Month
        pop     bp
        retf    4
Month   endp

;-------------------------------------------------------------------------------
;Function Year(var date_var:date):integer
;-------------------------------------------------------------------------------
Year    proc    far
        push    bp
        mov     bp,sp
        push    ds
        lds     si,dword ptr ss:[bp+6]
        call    _Year
        pop     bp
        retf    4
Year    endp

;-------------------------------------------------------------------------------
;Function Dtoc(var date_var:date):string
;-------------------------------------------------------------------------------
DTOC    proc    far
        push    bp
        mov     bp,sp
        push    ds
        pop     es
        push    ds
        lds     si,dword ptr ss:[bp+ 6]
        lea     di,Date_value
        push    di
        mov     cx,4
        cld
        rep     movsw
        pop     si
        pop     ds
        les     di,dword ptr ss:[bp+10]
        call    Make_Date_str
        pop     bp
        retf    4
DTOC    endp



American_type   equ     0
French_type     equ     1

Make_Date_Str   proc    near
; DS:SI = @Date_value
; ES:DI = @String
        push    si
        push    di

        mov     cl,10
MDS_1:
        mov     byte ptr es:[di],cl
        xor     ch,ch
        mov     al,' '
        cld
        inc     di
        rep     stosb
        pop     di
        push    di
        cmp     word ptr ds:[si+4],0
        je      MDS_4

        push    di

        add     di,7
        cld
        lodsw
        stosw
MDS_2:
        lodsw
        stosw
        lodsw
        pop     di
        inc     di
        cmp     Date_type,American_type
        jne     MDS_3
        stosw
        lodsw
        inc     di
        stosw
        jmp     MDS_4
MDS_3:
        add     di,3
        stosw
        lodsw
        sub     di,5
        stosw
MDS_4:
        pop     di
        pop     si
        mov     al,Date_separate
        mov     byte ptr es:[di+3],al
        mov     byte ptr es:[di+6],al
        ret
Make_Date_Str   endp

Make_Date_value proc  near
; DS:SI = @String
; ES:DI = @Date_value
; Return : CF = 1 --> error

        push    si
        push    di

        cmp     word ptr ds:[si+1],'  '
        jne     MDV_1
        clc
MDV_0:
        pop     di
        push    di
        pushf
        xor     ax,ax
        cld
        stosw
        stosw
        stosw
        stosw
        popf
        jmp     MDV_end
MDV_1:
        push    si
        add     si,7
        mov     ax,word ptr [si]
        add     si,2
MDV_11:
        mov     word ptr es:[di],ax
        mov     ax,word ptr [si]
        mov     word ptr es:[di+2],ax
        mov     cx,2
        call    _Atoi
        xor     bp,bp
        mov     bl,4
        div     bl
        or      ah,ah
        jnz     MDV_12
        inc     bp                      ; nam nhuan
MDV_12:
        pop     si
        push    si
        cmp     Date_type,American_type
        jne     MDV_2
        add     si,3
MDV_2:
        inc     si
        mov     ax,word ptr [si]
        mov     word ptr es:[di+6],ax
        mov     cx,2
        call    _Atoi
        pop     si
        push    ax                      ; AX = date
        mov     cl,byte ptr ds:[si]
        xor     ch,ch
        push    cx                      ; CX = Date_str length

        cmp     Date_type,American_type
        je      MDV_3
        add     si,3
MDV_3:
        inc     si
        mov     cx,2
        mov     ax,word ptr [si]
        mov     word ptr es:[di+4],ax
        call    _Atoi
        pop     cx                      ; CX = Date_str length
        push    ax                      ; AX = month
        mov     al,'?'
        mov     cx,10
        cld
        repne   scasb
        pop     ax                      ; AX = month
        pop     dx                      ; DX = date
        or      cx,cx
        jnz     MDV_OK                  ; No checked

        or      ax,ax
        jz      MDV_error
        cmp     ax,12
        ja      MDV_error

        or      dx,dx
        jz      MDV_error

        cmp     ax,2                    ; 2
        jne     MDV_4
        add     bp,28
        cmp     dx,bp
        ja      MDV_error
        jbe     MDV_OK
MDV_4:
        mov     bp,30
        cmp     ax,7                    ; 1,3,4,5,6,7
        ja      MDV_5
        shr     ax,1                    ; Neu thang le --> inc bp
        adc     bp,0
        jmp     MDV_6
MDV_5:
        inc     bp                      ; 8,10,12
        shr     ax,1                    ; BP = 31
        sbb     bp,0                    ; Neu thang chan --> dec bp
MDV_6:
        cmp     dx,bp
        jbe     MDV_OK
MDV_error:
        stc
        jmp     MDV_0
MDV_OK:
        clc
MDV_end:
        pop     di
        pop     si
        ret
Make_Date_value endp

EMP_VNI_Load    proc    far
        ; set vni font
        mov     byte ptr EMP_VNI_KEY, 1
        push    es

        push    cs
        pop     es

        mov     ax, 01100h
        mov     bl, 0
        mov     bh, 16
        mov     BP, offset font
        xor     dx, dx
        mov     cx, 256
        int     010h

        pop     es
        retf
EMP_VNI_Load    endp

EMP_VNI_Unload  proc    far
        ; reset font
        mov     byte ptr EMP_VNI_KEY, 0
        mov     ax, 01130h
        mov     bh, 5
        int     010h                    ; check screen type
        mov     ax, 01104h
        cmp     cl, 14
        jne     KT
        sub     al, 3
     KT:
        mov     bl, 0
        int     010h

        retf
EMP_VNI_UnLoad  endp
        ; Chars to chage = 15
CharSet db 'a','Ë','É','d','D','e','à','i','o','ì','Û','u','ü','c','C','y'
        db '†','È','„','d','D','Ç','â','°','¢','ñ','Ù','£','§','c','C','Ó'
        db 'Ö','Í','‰','d','D','ä','ã','ç','ï','ò','ı','ó','•','c','C','Ô'
        db '‡','Î','Â','d','D','Å','é','©','ë','ô','ˆ','ú','¶','c','C',''
        db '·','Ï','Ê','d','D','Ñ','è','™','í','ö','˜','ù','ß','c','C','Ò'
        db '‚','Ì','Á','d','D','Ü','¨','´','î','õ','¯','û','®','c','C','Ú'
        db 'É','É','É','d','D','à','à','å','ì','ì','ì','Ø','Ø','c','C','y'
        db 'a','Ë','É','d','D','e','à','i','Û','Û','Û','ü','ü','c','C','y'
        db 'Ë','Ë','Ë','d','D','e','à','i','o','ì','Û','u','ü','c','C','y'
        db '¸','¸','¸','≠','Æ','˝','˝','ê','˙','˙','˙','˚','˚','á','Ä','y'
CharEnd db 0
ChrStop db 0

font:
        include EMP_VNI.DAT
code    ends
        end
