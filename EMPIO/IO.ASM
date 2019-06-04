
True_value      equ     1
False_value     equ     0

American_type   equ     0
French_type     equ     1

;       DS:0016       HEAPORG           0
;       DS:001A       HEAPPTR           4
;       DS:001E       HEAPEND           8
;       DS:0022       FREELIST         12
;       DS:0026       FREEZERO         16
;       DS:002A       HEAPERROR        20
;       DS:001E       HEAPEND          24

Data    segment public

        Extrn HEAPORG      : word
        Extrn HEAPPTR      : word

        EXTRN Video_seg    : word
        EXTRN CRT_port     : word
        EXTRN Check_snow   : byte
        EXTRN row          : byte
        EXTRN col          : byte
        EXTRN color        : byte
        EXTRN get_color    : byte
        EXTRN Ins_flag     : byte
        EXTRN Zoom_mode    : byte
        EXTRN Box_Base     : byte

        EXTRN GS_check     : byte
        EXTRN get_confirm  : byte
        EXTRN get_mode     : byte
        EXTRN get_count    : word
        EXTRN prompt_count : word
        EXTRN get_point    : word
        EXTRN prompt_point : word
        EXTRN Brow_point   : word

        EXTRN Date_separate : byte
        EXTRN Date_type     : byte

        EXTRN HOUR          : byte
        EXTRN MINUTE        : byte
        EXTRN SECOND        : byte
        EXTRN MILI_SECOND   : byte

        Cursor_size     dw      0
        Cursor_addr     dw      0
        Video_Buff      dd      0

        Str_Frame       db     10 dup (0)
        Zoom_Step       dw      1
        ZA1             dw      0
        ZA2             dw      0
        Zoom_flag       db      0
        old_color       db      0

        EXTRN Out_stat : word
        EXTRN prow     : word
        EXTRN pcol     : word
        EXTRN OCB      : byte

        Cur_prow        dw      0
        Cur_pcol        dw      0
        SP_str          db      32
        FF_str          db      12
        CR_str          db      13
        LF_str          db      10

Data    ends

Code    segment public
        assume  cs:code,ds:data
        Public  EMPIO_Init, WScr, Backup_Screen, Restore_Screen
        public  Write_Str, Gotoxy, Textcolor, TextBackground
        public  Out_To_File, Out_To_screen, Eject, Reset_PRN
        Public  Clear, ClrScr, Inkey, Inchar, KeyPressed, Cursor_on, Cursor_off
        Public  Delay, Gettime, Sound, Sound_on, Sound_off, NoSound
        Public  GetIntVec, SetIntVec, RunAddr; , exec, GetExcPath
        Public  box, zoom, scroll, Set_Attrib, Fill_char


        db      'IO Library. (C) Copyright AZ-Group 1990-1995, EMP. 1997  '
        db      10,13

;-------------------------------------------------------------------------------
;Procedure EMPIO_init
;-------------------------------------------------------------------------------
EMPIO_Init proc  far

        mov     color,7
        mov     get_color,0+7*16

        mov     Date_separate,'/'
        mov     Date_type    ,French_type

        xor     ax,ax
        mov     Ins_flag,al
        mov     Zoom_mode,al
        mov     Box_base ,al
        mov     row,al
        mov     col,al

        mov     Get_mode,al
        mov     Get_Confirm,False_value
        mov     GS_Check,False_value
        mov     Get_count,ax
        mov     Prompt_count,ax
        mov     Get_point,ax
        mov     Prompt_point,ax
        mov     Brow_point  ,ax

        mov     Video_seg,0B800h
        push    es
        xor     ax,ax
        mov     es,ax
        cmp     byte ptr es:[449h],7    ; Display mode
        jne     IO_1
        mov     Video_seg,0B000h        ; Mono adaptor
        jmp     IO_2
IO_1:
        cmp     word ptr es:[044Ah],80  ; Text mode 80*25 ?
        je      IO_2
        cmp     byte ptr es:[0462h],0   ; Page 0 ?
        je      IO_2

        mov     ax,3                    ; Reset mode
        int     010h
IO_2:
        mov     cx,word ptr es:[0460h]
        mov     Cursor_size,cx
        mov     dx,word ptr es:[0450h]
        mov     Cursor_addr,dx
        mov     row,dh
        mov     col,dl

        mov     dx,word ptr es:[0463h]  ; DX = 6845 addr port
        mov     CRT_port,dx
IO_3:
        pop     es

        mov     ax,HeapOrg[2]                   ; Heap_top segment
        mov     word ptr Video_Buff[0],0
        mov     word ptr Video_Buff[2],ax       ; Alocate 16 KB for
        add     ax,0400h                        ; Video buffer
        mov     HeapOrg[ 0+2],ax                ; Heap_org  segment
        mov     HeapOrg[ 4+2],ax                ; Heap_ptr  segment
        mov     HeapOrg[12+2],ax                ; Free_list segment

        push    ds
        push    cs
        pop     ds
        lea     dx,C_error
        mov     ax,02524h
        int     021h
        pop     ds

        retf

EMPIO_Init endp

Make_Video_addr proc near

        ; Input :
        ;   DH    = row
        ;   DL    = col
        ; Output:
        ;   ES:DI = video position
        ;

        push    ax
        push    dx
        mov     ah,dh
        mov     al,80
        mul     ah
        mov     di,ax
        xor     dh,dh
        add     di,dx
        shl     di,1
        push    ds
        mov     ax,Data
        mov     ds,ax
        mov     es,Video_seg
        pop     ds
        pop     dx
        pop     ax
        call    Video_wait
        ret

Make_Video_addr endp

Video_wait      proc    near
        cmp     cs:Check_snow,False_value
        jne     VW_1
        ret
VW_1:
        push    ax
        push    dx
        push    ds
        mov     ax,Data
        mov     ds,ax
        mov     dx,CRT_port             ; DX = 6845 addr port
        pop     ds
        add     dx,6                    ; DX = 6845 status port
VW_2:
        in      al,dx                   ; Nâu ≠ang quÇt ngü¯c (retrace)
        test    al,1                    ; thç chı cho ≠ân khi bÈt ≠‰u
        jnz     VW_2                    ; quÇt trˆ l‚i
VW_3:
        in      al,dx                   ; Chı cho ≠ân khi bÈt ≠‰u quÇt
        test    al,1                    ; ngü¯c
        jz      VW_3

        pop     dx
        pop     ax
VW_end:
        ret
Video_wait      endp

WSCR    PROC    NEAR
        ; DH     = row
        ; DL     = col
        ; AH     = attrib
        ; CL     = len
        ; DS:SI  = @ buffer

        cld
        push    ax
        push    bx
        push    cx
        push    dx
        push    di
        push    si

        mov     byte ptr old_color, ah
        call    Make_Video_addr
        xor     ch,ch

        or      cx,cx
        jz      WS_end
WS_1:                           ; Attribute Color Value:
        lodsb                   ; x x x x
        cmp     al, 15          ; | |   |
        ja      WS_11           ; | + - + - Sub-Color Value
        test    al, 8           ; + ------- Blink Color
        jz      WS_10           ; Not blink
        add     ah, 136         ; include 128 + 8 to set blink
WS_10:
        sub     ah, al
        mov     al, ' '
        jmp     WS_13
WS_11:
        cmp     al, '`'
        je      WS_12
;       cmp     al, '.'
;       je      WS_12
        cmp     al, '~'
        jne     WS_13
        mov     al, ' '
WS_12:
        mov     ah, old_color
        cmp     al, '`'
        je      WS_1
WS_13:
        stosw
        loop    WS_1
WS_end:
        mov     bp,si
        inc     bp
        pop     si
        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        push    cs
        pop     es
        ret

WSCR    endp

Adjust_Cursor_addr      proc    near

ACA_begin:
        cmp     col,79
        jbe     ACA_end
        sub     col,80
        inc     row
        jmp     ACA_begin
ACA_end:
        ret
Adjust_Cursor_addr      endp

Write_str       proc far
        push    bp
        mov     ah,byte ptr color
        mov     dh,byte ptr row
        mov     dl,byte ptr col
        xor     cx,cx
        xchg    cx,word ptr OCB[BufPos]       ; BufPos
        add     byte ptr col,cl
        call    Adjust_Cursor_addr
        mov     bx,word ptr OCB[Handle]
        or      bx,bx
        jnz     Write_File
Write_screen:
        push    ds
        lds     si,dword ptr OCB[BufPtr]      ; Buffer
        call    WScr
        pop     ds
        call    Set_cur_pos
        jmp     Write_end
Write_File:
        cmp     Out_Stat,0
        je      WF_0
        jmp     Write_end
WF_0:
        push    cx
WF_1:
        xor     cx,cx
        mov     cx,prow
        cmp     cx,Cur_prow
        jb      WF_11
        sub     cx,Cur_prow
        jcxz    WF_2
        jmp     WF_12
WF_11:
        push    cx
        lea     dx,FF_str
        mov     cx,1
        mov     ah,040h
        int     021h
        pop     cx
        jcxz    WF_2
WF_12:
        push    cx
        lea     dx,Cr_str               ; CR_str + LF_str
        mov     cx,2
        mov     ah,040h
        int     021h
        pop     cx
        loop    WF_12
WF_2:
        xor     cx,cx
        mov     cx,pcol
        cmp     cx,Cur_pcol
        jb      WF_21
        sub     cx,Cur_pcol
        jcxz    WF_3
        jmp     WF_22
WF_21:
        jcxz    WF_3
        push    cx
        lea     dx,CR_str
        mov     cx,1
        mov     ah,040h
        int     021h
        pop     cx
WF_22:
        push    cx
        lea     dx,SP_str
        mov     cx,1
        mov     ah,040h
        int     021h
        pop     cx
        loop    WF_22
WF_3:
        les     di,dword ptr OCB[BufPtr]     ; Buffer
        pop     cx
        push    cx
WF_41:
        cmp     byte ptr es:[di],10
        jne     WF_4
        inc     prow
        jmp     WF_5
WF_4:
        cmp     byte ptr es:[di],13
        jne     WF_5
        mov     pcol,0
        jmp     WF_6
WF_5:
        inc     pcol
WF_6:
        inc     di
        loop    WF_41

        mov     cx,pcol
        mov     Cur_pcol,cx
        mov     cx,prow
        mov     Cur_prow,cx

        pop     cx
        push    ds
        lds     dx,dword ptr OCB[BufPtr]     ; Buffer
        mov     ah,040h
        int     021h
        pop     ds
Write_end:
        xor     ax,ax
        pop     bp
        ret     4
Write_str   endp

Set_cur_pos     proc    near
        xor     bx,bx
        mov     dh,row
        mov     dl,col
        mov     ah,2
        int     010h
        ret
Set_cur_pos     endp


;-------------------------------------------------------------------------------
;Procedure Backup_Screen
;-------------------------------------------------------------------------------
Backup_Screen   proc far
        push    ds
        mov     ax,Data
        mov     ds,ax
        cmp     word ptr Video_buff,12000
        jae     BS_end
        mov     ax,Video_Seg
        les     di,dword ptr Video_buff
        add     word ptr Video_buff,4002
        mov     ds,ax
        xor     si,si
        mov     cx,2000
        cld
        cli
        rep     movsw
        sti
        xor     ax,ax
        mov     ds,ax
        mov     ax,word ptr ds:[0450h]
        stosw
BS_end:
        pop     ds
        retf
Backup_Screen   endp


;-------------------------------------------------------------------------------
;Procedure Restore_Screen
;-------------------------------------------------------------------------------
Restore_Screen  proc far
        push    ds
        mov     ax,Data
        mov     ds,ax
        cmp     word ptr Video_buff,0
        je      RS_end
        sub     word ptr Video_buff,4002
        mov     ax,Video_Seg
        lds     si,dword ptr Video_buff
        mov     es,ax
        xor     di,di
        mov     cx,2000
        cld
        cli
        rep     movsw
        sti
        lodsw
        mov     dx,ax
        mov     ah,2
        xor     bx,bx
        int     010h
RS_end:
        pop     ds
        retf
Restore_Screen  endp


;------ Output structure -------------------------------------------------------

        Handle          equ    0      ; word;
        Mode            equ    2      ; Word;
        BufSize         equ    4      ; Word;
        Private         equ    6      ; Word;
        BufPos          equ    8      ; Word;
        BufEnd          equ   10      ; Word;
        BufPtr          equ   12      ; ^TextBuf;
        OpenFunc        equ   16      ; Pointer;
        InOutFunc       equ   20      ; Pointer;
        FlushFunc       equ   24      ; Pointer;
        CloseFunc       equ   28      ; Pointer;
        UserData        equ   32      ; array[1..16] of byte;
        FName           equ   48      ; array[0..79] of char;
        Buffer          equ  128      ; TextBuf;

;-------------------------------------------------------------------------------
;Procedure Out_To_Screen
;-------------------------------------------------------------------------------
Out_To_Screen      proc far
        push    bp
        mov     bx,word ptr OCB[Handle]
        or      bx,bx
        jz      OT_S1
        xor     cx,cx
        mov     ah,040h
        int     021h                            ; Truncated file

        mov     ah,03Eh                         ; Close file
        int     021h
        mov     word ptr OCB[Handle],0
OT_S1:
        pop     bp
        retf
Out_To_Screen      endp


Rewrite_mode    equ   0
Append_mode     equ   1
;-------------------------------------------------------------------------------
;Procedure Out_To_File(File_name:string,mode:byte);
;-------------------------------------------------------------------------------
Out_To_File        proc far
        push    bp
        mov     bp,sp
        push    ds
        pop     es
        push    ds
        mov     bx,word ptr OCB[Handle]
        or      bx,bx
        jz      OT_F1
        mov     ah,03Eh
        int     021h
OT_F1:
        lds     si,dword ptr ss:[bp+8]
        mov     cl,byte ptr ds:[si]
        xor     ch,ch
        inc     si
        lea     di,OCB[FName]
        push    di
        cld
        rep     movsb
        mov     byte ptr es:[di],0

        pop     dx
        pop     ds
        mov     ax,03D02h
        push    dx
        int     021h
        pop     dx
        jnc     OT_F2
        cmp     ax,2
        je      OT_created
        jne     OT_error
OT_created:
        mov     ax,03C00h               ; If file not exist , new file was
        mov     cx,020h                 ;  created
        int     021h
        jnc     OT_F2
OT_error:
        xor     ax,ax
OT_F2:
        mov     word ptr OCB[Handle],ax
        mov     bx,ax
        cmp     byte ptr ss:[bp+6],Append_mode
        jne     OT_F3
        mov     ax,04202h
        xor     cx,cx
        mov     dx,cx
        int     021h
OT_F3:
        mov     ax,04400h
        int     021h            ; Get device information

        xor     dh,dh
        or      dl,020h         ; Set binary mode
        mov     ax,04401h
        int     021h

        mov     prow,0
        mov     pcol,0
        mov     Cur_prow,0
        mov     Cur_pcol,0

        mov     SP_str,32
        mov     LF_str,10
        mov     CR_str,13
        mov     FF_str,12

        mov     Out_Stat,0

        pop     bp
        retf    6
Out_To_File        endp

;-------------------------------------------------------------------------------
;Procedure Eject
;-------------------------------------------------------------------------------
Eject   proc    far
        push    bp
        mov     bx,word ptr OCB[Handle]
        or      bx,bx
        jz      Eject_end
        cmp     Out_Stat,0
        jne     Eject_end
        lea     dx,FF_str                       ; FF_str + CR_str + LF_str
        mov     cx,3
        mov     ah,040h
        int     021h
Eject_end:
        mov     prow,0
        mov     pcol,0
        mov     Cur_prow,0
        mov     Cur_pcol,0
        pop     bp
        retf
Eject   endp

;-------------------------------------------------------------------------------
;Procedure Reset_PRN
;-------------------------------------------------------------------------------
Reset_PRN       proc    far
        push    bp
        mov     ah,1
        xor     dx,dx
        int     017h
        mov     prow,0
        mov     pcol,0
        mov     Cur_prow,0
        mov     Cur_pcol,0
        pop     bp
        ret
Reset_PRN       endp

;-------------------------------------------------------------------------------
; Procedure Gotoxy(col,row:byte)
;-------------------------------------------------------------------------------
Gotoxy  proc    far
        push    bp
        mov     bp,sp
        mov     cx,word ptr ss:[bp+6]
        mov     dx,word ptr ss:[bp+8]
        mov     bx,word ptr OCB[Handle]
        or      bx,bx
        jz      GT_1
        mov     prow,cx
        mov     pcol,dx
        jmp     GT_2
GT_1:
        mov     row,cl
        mov     col,dl
        call    Set_cur_pos
GT_2:
        pop     bp
        retf    4
Gotoxy  endp

;-------------------------------------------------------------------------------
; Procedure TextColor(color:byte)
;-------------------------------------------------------------------------------
TextColor  proc    far
        push    bp
        mov     bp,sp
        mov     al,byte ptr ss:[bp+6]
        and     al,10001111b
        and     color,01110000b
        or      color,al
        pop     bp
        retf    2
TextColor  endp

;-------------------------------------------------------------------------------
; Procedure TextBackground(color:byte)
;-------------------------------------------------------------------------------
TextBackground  proc    far
        push    bp
        mov     bp,sp
        mov     al,byte ptr ss:[bp+6]
        and     al,01110000b
        and     Color,10001111b
        or      color,al
        pop     bp
        retf    2
TextBackground  endp

;-------------------------------------------------------------------------------
; Function Inchar:char
;-------------------------------------------------------------------------------
Inchar  proc  far
Inchar  endp

;-------------------------------------------------------------------------------
; Function Inkey:word
;-------------------------------------------------------------------------------
Inkey   proc  far
        xor   ax,ax
        int   016h
        retf
Inkey   endp

;-------------------------------------------------------------------------------
; Function KeyPressed:boolean
;-------------------------------------------------------------------------------
KeyPressed    proc  far
        mov   ah,1
        int   016h
        mov   ax,True_value
        jnz   KP1
        xor   ax,ax     ; False_value
KP1:
        retf
KeyPressed    endp

;-------------------------------------------------------------------------------
; Procedure ClrScr
;-------------------------------------------------------------------------------
ClrScr   proc   far

        ; For compatible with CRT unit

ClrScr   endp

;-------------------------------------------------------------------------------
; Procedure Clear
;-------------------------------------------------------------------------------
Clear   proc   far
        xor    cx,cx
        mov    row,cl
        mov    col,cl
        mov    dh,24
        mov    dl,79
        mov    bh,byte ptr Color
        mov    ax,0600h
        int    010h
        retf
Clear   endp

;-------------------------------------------------------------------------------
; Procedure Cursor_off
;-------------------------------------------------------------------------------
Cursor_off      proc    far
        mov     ah,1
        mov     cx,02000h
        int     010h
        ret
Cursor_off      endp

;-------------------------------------------------------------------------------
; Procedure Cursor_on
;-------------------------------------------------------------------------------
Cursor_on       proc    far
        mov     ah,1
        mov     cx,Cursor_size
        int     010h
        ret
Cursor_on       endp

;-------------------------------------------------------------------------------
; Procedure  GetTime
;-------------------------------------------------------------------------------

Gettime  proc  far

        ; DX:AX = Time_count
        push    es
        xor     ax,ax
        mov     es,ax
        mov     ax,word ptr es:[046Ch]
        mov     dx,word ptr es:[046Eh]     ; DX:AX = time_count
        pop     es

        ; DX:AX = Time_count
        mov     bx,ax
        mov     cx,dx
; Time_count = tong so giay tinh tu 0 gio *(1193180/65535)

; Nhan Time_count voi 5 roi dat ket qua vao DX:AX
        shl     ax,1
        rcl     dx,1            ; Nhan 2
        shl     ax,1
        rcl     dx,1            ; Nhan 2
        add     ax,bx
        adc     dx,cx           ; Cong don  1+2*2=5
; Goi gia tri thu duoc tai day la (1)

; Chia ket qua cho 59659 . Chu y : 59659=1193180/20
        mov     cx,59659
        div     cx
        mov     bx,ax           ; Cat ket qua vao BX
        xor     ax,ax           ; DX:AX = so du * 65535
        div     cx
        mov     dx,bx
; DX:AX = (1)*65535/59659

        mov     cx,200
        div     cx
        push    dx              ; giu so du

; AX = (Time_count*65535/1193180)/2 = (so giay tu 0 gio)/2
        mov     bl,100
        sub     bl,dl           ; Kiem tra so du
; Neu DL > 100 --> BL < 0  --> CF=1

; Nhan ket qua voi 2 --> so giay tinh tu 0 gio
        rcl     ax,1            ; Neu so du cua phep chia cho 200
        mov     dx,0            ; lon hon 100 thi cong them 1 vao
        rcl     dx,1            ; ket qua

        mov     cx,60
; giay = (tong so giay) mod 60
        div     cx                      ; AX = tong so phut
        mov     byte ptr second, dl     ; dl = so giay
; phut = (tong so phut) mod 60
        div     cl
        mov     byte ptr minute, ah     ; ah = so phut
        mov     byte ptr hour, al       ; al = so gio

; so mili seconds
        pop     ax
        mov     cl, 100
        div     cl                      ; DX = so mili seconds
        mov     byte ptr mili_second, ah

        ret

Gettime  endp

;-------------------------------------------------------------------------------
; Function  GetExcPath;
;-------------------------------------------------------------------------------
;GetExcPath proc far
;        push    bp
;        mov     bp, sp
;        push    ds
;        push    es
;        mov     ah, 062h
;        int     021h
;        mov     es, bx                          ; PSP segment
;        mov     ax, word ptr ES:[02Ch]
;        mov     es, ax
;        xor     di, di
;        mov     al, 0
;ge1:
;        cld
;        mov     cx, 0FFFFh
;        Repne   scasb
;        or      byte ptr es:[di], 0
;        jne     ge1
;
;        add     di, 3
;        lds     si, dword ptr ss:[bp+6]
;        inc     si
;        xor     cl, cl
;ge2:
;        mov     al, byte ptr es:[di]
;        or      al, al
;        jz      ge3
;        mov     byte ptr ds:[si], al
;        inc     si
;        inc     di
;        inc     cl
;        jmp     ge2
;ge3:
;        lds     si, dword ptr ss:[bp+6]
;        mov     byte ptr ds:[si], cl
;        pop     es
;        pop     ds
;        pop     bp
;        retf
;GetExcPath endp
;-------------------------------------------------------------------------------
; Procedure  GetIntVec(IntNo: Byte, var IntAddr: Pointer)
;-------------------------------------------------------------------------------
GetIntVec proc  far
        push    bp
        mov     bp, sp
        push    es
        push    ds

        mov     ax, word ptr ss:[bp+10]
        mov     ah, 035h
        int     021h                            ; ES:BX -> Int Process

        lds     si, dword ptr ss:[bp+6]
        mov     word ptr ds:[si], bx
        mov     word ptr ds:[si+2], es

        pop     ds
        pop     es
        pop     bp
        Ret
GetIntVec endp

;-------------------------------------------------------------------------------
; Procedure  SetIntVec(IntNo: Byte, IntAddr: Pointer)
;-------------------------------------------------------------------------------
SetIntVec proc  far
        push    bp
        mov     bp, sp
        push    ds

        mov     ax, word ptr ss:[bp+10]
        lds     dx, dword ptr ss:[bp+6]
        mov     ah, 025h
        int     021h

        pop     ds
        pop     bp
        ret
SetIntVec endp

;-------------------------------------------------------------------------------
; Procedure  RunAddr(Addr: Pointer)
;-------------------------------------------------------------------------------
RunAddr proc  far
        push    bp
        mov     bp, sp
        push    ds

        pushf
        call    dword ptr ss:[bp+6]

        pop     ds
        pop     bp
        retf
RunAddr endp

;-------------------------------------------------------------------------------
; Procedure  Exec(command, command line)
;-------------------------------------------------------------------------------
;exec proc far
;     PUSH BP
;     MOV BP,SP
;     MOV word ptr ds:[52h],SP
;     MOV word ptr ds:[54h],SS
;     SUB SP,0FEh
;     MOV DS,word ptr ds:[38h]
;     MOV AX,word ptr ds:[2Ch]
;     MOV word ptr ds:[BP-0Eh],AX
;     PUSH SS
;     POP ES
;     CLD
;     LDS SI,[BP+0Ah]
;     LEA DI,[BP-7Eh]
;     LODSB
;     CMP AL,4Fh
;     JB tuc1
;     MOV AL,4Fh
;tuc1:
;     CBW
;     XCHG AX,CX
;     REP MOVSB
;     XOR AL,AL
;     STOSB
;     LDS SI,[BP+6]
;     LEA DI,[BP-0FEh]
;     LODSB
;     CMP AL,7Eh
;     JB tuc2
;     MOV AL,7Eh
;tuc2:
;     STOSB
;     CBW
;     XCHG AX,CX
;     REP MOVSB
;     MOV AL,Dh
;     STOSB
;     PUSH SS
;     POP DS
;     LEA SI,[BP-0FEh]
;     MOV word ptr ds:[BP-0Ch],SI
;     MOV word ptr ds:[BP-0Ah],DS
;     INC SI
;     LEA DI,[BP-1Eh]
;     MOV word ptr ds:[BP-8],DI
;     MOV word ptr ds:[BP-6],ES
;     MOV AX,2901h
;     INT 21h
;     LEA DI,[BP-2Eh]
;     MOV word ptr ds:[BP-4],DI
;     MOV word ptr ds:[BP-2],ES
;     MOV AX,2901h
;     INT 21h
;     LEA DX,[BP-7Eh]
;     LEA BX,[BP-0Eh]
;     MOV AX,4B00h
;     INT 21h
;     JB  tuc3
;     XOR AX,AX
;tuc3:
;     MOV DX,223Ah
;     MOV DS,DX
;     CLI
;     MOV SP,word ptr ds:[52h]
;     MOV SS,word ptr ds:[54h]
;     STI
;     MOV word ptr ds:[50h],AX
;     POP BP
;     RETF 8
;exec endp

;-------------------------------------------------------------------------------
; Procedure  Delay(Count:word)
;-------------------------------------------------------------------------------
Delay   proc    far
        ; Procedure  Delay(Count:word)
        mov     bx,sp
        mov     cx,word ptr ss:[bx+4]
        or      cx,cx
        jz      Delay_end
        call    _Delay
Delay_end:
        retf    2
Delay   endp

_Delay  proc    near
        ;
        ; CX = Delay_count (1/50 second)
        ;

        mov     dx,CRT_port             ; DX = 6845 addr port
        add     dx,6                    ; DX = 6845 status port
DL_1:
        in      al,dx                   ; Dóng chu kÔ quÇt mÖnh ≠é t‚o
        test    al,8                    ; thıi gian trè .
        jnz     DL_1                    ; Mõt chu kÔ quÇt mÖnh kÇo dÖi
DL_2:                                   ; kho‡ng 1/50 giÉy
        in      al,dx
        test    al,8
        jz      DL_2                    ; Æang quÇt mÖnh
        loop    DL_1
        ret

_Delay  endp


;-------------------------------------------------------------------------------
; Procedure  Sound(Freq:word)
;-------------------------------------------------------------------------------
Sound   proc    far
        push    bp
        mov     bp,sp
        mov     bx,word ptr ss:[bp+6]
        cmp     bx,20
        jb      Sound_1

        call    Sound_on
        mov     dx,00012h       ; Count = 1193180/Freq
        mov     ax,034DCh
        div     bx
        mov     bx,ax

        mov     al,10110110b    ; Yàu c‰u ≠´nh mode 3 cho channel-2
        out     043h,al         ; ≠òng thıi n‚p gi† tr´ mÙi cho SCR
        mov     al,bl
        out     042h,al         ; Load low byte
        mov     al,bh
        out     042h,al         ; Load high byte
Sound_1:
        pop     bp
        retf    2
Sound   endp

;-------------------------------------------------------------------------------
; Procedure  Sound_on
;-------------------------------------------------------------------------------
Sound_on    proc  far
        in   al,61h              ; BÁt loa
        or   al,3                ;  bÍng c†ch cho bit 0 vÖ bit 1
        out  61h,al              ;  công 61h bÍng 1
        ret
Sound_on  endp

;-------------------------------------------------------------------------------
; Procedure  Sound_off
;-------------------------------------------------------------------------------
NoSound      proc  far
NoSound      endp
Sound_off    proc  far
        in   al,61h              ; TÈt loa
        and  al,0fch             ;  bÍng c†ch cho bit 0 vÖ bit 1
        out  61h,al              ;  công 61h bÍng 0
        ret
Sound_off  endp


_Write proc near
      xor  bx,bx
hh:
      inc  bx
      cmp  byte ptr [si+bx],0
      jne  hh
      mov  cx,bx
      jmp  WSCR
_Write endp
;--------------------  Critical error

Single_frame    db  9,'⁄ƒø≥Ÿƒ¿≥ '       ;  { string[9] }
CTE_color       equ 15+4*16

C_error proc    near
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    bp
        push    ds
        push    es

        mov     bx,data
        mov     ds,bx
        push    ds
CE0:

        and     ah,3
        mov     cs:CTE_area,ah
        mov     bx,di
        and     bl,07Fh
        mov     cs:CTE_code,bl

        sti
        mov     ah,color
        push    ax
        call    Backup_screen
        mov     color,CTE_color
        mov     zoom_mode,1

        ;Zoom   9,18,17,62,single_frame
        mov     ax,9
        push    ax
        mov     ax,18
        push    ax
        mov     ax,17
        push    ax
        mov     ax,62
        push    ax
        push    cs
        mov     ax,offset single_frame
        push    ax
        call    zoom

        pop     ax
        mov     color,ah

        mov     ax,cs
        mov     ds,ax
        mov     es,ax

        mov     dh,11
        mov     dl,33
        lea     si,CTE_mess1
        mov     ah,CTE_color
        call    _write


        mov     bl,CTE_code
        lea     di,C_table
        mov     al,0
        mov     cx,0FFFFh
        cld
CE1:
        cmp     byte ptr [di],0FFh
        je      CE2
        cmp     byte ptr [di],bl
        je      CE2
        inc     di
        repne   scasb
        jmp     CE1
CE2:
        inc     di
        mov     dl,byte ptr [di]
        mov     dh,13
        mov     si,di
        inc     si
        mov     ah,CTE_color
        call    _write

        mov     dh,15
        mov     dl,26
        lea     si,CTE_mess2
        mov     ah,CTE_color
        call    _write
CE3:
        xor     ax,ax
        int     016h

        cmp     al,'a'
        jb      CE4
        sub     al,'a'-'A'
CE4:
        cmp     al,'F'
        jne     CE41
        mov     ax,3
        jmp     CE6
CE41:
        cmp     al,'R'
        jne     CE42
        mov     ax,1
        jmp     CE6
CE42:
        cmp     al,'I'
        jne     CE3
        mov     ax,0
CE6:
        pop     ds
        mov     Out_Stat,ax
        push    ax
        call    Restore_screen
        pop     ax
CE7:
        pop     es
        pop     ds
        pop     bp
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        iret

C_error endp

CTE_mess1       db         'Critical  Error',0
CTE_mess2       db      'R`etry  , I`gnore  , F`ail ?',0

CTE_area        db      0
CTE_code        db      0

C_table db      0,21,  'Unable writing on write-protected disk',0
        db      1,32,            'Invalid drive ID'            ,0
        db      2,32,            'Drive not ready'             ,0
        db      4,35,               'CRC error'                ,0
        db      6,32,            'Disk seek error'             ,0
        db      7,31,           'Invalid disk media'           ,0
        db      8,32,            'Sector not found'            ,0
        db      9,30,          'Printer out of paper'          ,0
        db     10,31,           'Printer not ready'            ,0
        db     12,32,            'General Failure'             ,0
        db   0FFh,31,           'Nonspecific error'            ,0

;--------------------

Include ZB.DAT

code    ends
        end
