Cur_up          equ  04800h
Cur_down        equ  05000h
Cur_left        equ  04B00h
Cur_right       equ  04D00h
ESC_key         equ  0011Bh
Enter_key       equ  01C0Dh
PgUp_key        equ  04900h
PgDn_key        equ  05100h
Home_key        equ  04700h
End_key         equ  04F00h

Data    segment public

        EXTRN  get_color     :  BYTE
        EXTRN  color         :  BYTE
        Extrn  Brow_point    :  word
        Extrn  Exit_key      :  word

;--- Brow parameter will be placed here
        Brow_addr     dd     0
        max_num       dw     0
        disp_num      dw     0
        ele_size      dw     0
        col           dw     0
        row           dw     0

        Brow_Top      dw     0
        Brow_bot      dw     0

Data    ends

Code    segment public
        assume  cs:code,ds:data
        Public brow

        EXTRN   WScr  :  near

Brow    proc    far
        ; Procedure Brow(row,col,ele_size,disp_num,max_num:word;buffer:pointer);

        push    bp
        push    ds
        pop     es
        lea     di,Brow_addr
        push    ss
        pop     ds

        mov     si,sp
        add     si,6
        mov     cx,14
        cld
        rep     movsb
        push    es
        pop     ds

        mov     bx,Brow_point
        mov     Brow_Top,1
        mov     ax,Disp_num
        cmp     bx,ax
        jbe     BR1
        dec     bx
        mov     Brow_top,bx
        add     ax,bx
        dec     ax
        cmp     ax,Max_num
        jbe     BR1
        sub     ax,max_num
        sub     Brow_top,ax
        mov     ax,Max_num
BR1:
        mov     Brow_Bot,ax
BR2:
        call    disp_brow
BR3:
        xor     ax,ax
        int     016h
        mov     Exit_key,ax

        cmp     ax,cur_up
        jne     BR4
        mov     ax,Brow_point
        cmp     ax,Brow_Top
        je      BR31
        dec     word ptr Brow_point
        jmp     short BR2
BR31:
        cmp     Brow_Top,1
        je      BR2
        dec     word ptr Brow_point
        dec     word ptr Brow_Top
        dec     word ptr Brow_Bot
        jmp     short BR2
BR4:
        cmp     ax,cur_down
        jne     BR5
        mov     ax,Brow_point
        cmp     ax,Brow_Bot
        je      BR41
        inc     word ptr Brow_point
        jmp     short BR2
BR41:
        mov     ax,Max_num
        cmp     Brow_Bot,ax
        je      BR2
        inc     word ptr Brow_point
        inc     word ptr Brow_Top
        inc     word ptr Brow_Bot
BR21:
        jmp     short BR2
BR5:
        cmp     ax,PgUp_key
        jne     BR6
        mov     ax,Disp_num
        cmp     ax,Brow_Top
        jb      BR51
        mov     ax,Brow_Top
        dec     ax
BR51:
        sub     word ptr Brow_Top,ax
        sub     word ptr Brow_point,ax
        sub     word ptr Brow_Bot,ax
        jmp     short BR21
BR6:
        cmp     ax,PgDn_key
        jne     BR7
        mov     ax,Disp_num
        mov     bx,ax
        add     bx,Brow_Bot
        cmp     bx,Max_num
        jb      BR61
        mov     ax,Max_num
        sub     ax,Brow_Bot
BR61:
        add     Brow_Top,ax
        add     Brow_point,ax
        add     Brow_Bot,ax
        jmp     short BR21
BR7:
        cmp     ax,Home_key
        jne     BR8
        mov     ax,Brow_Top
        mov     Brow_point,ax
        jmp     short BR21
BR8:
        cmp     ax,End_key
        jne     BR9
        mov     ax,Brow_Bot
        mov     Brow_point,ax
        jmp     short BR21
BR9:
        pop     bp
        retf    14

Brow    endp

Disp_brow   proc  near
        mov     cx,Brow_Bot
        sub     cx,Brow_Top
        inc     cx
        mov     ax,word ptr Brow_Top
        call    Take_brow_addr
        mov     ah,byte ptr color
        mov     al,byte ptr row
DB1:
        push    cx
        push    ax
        call    disp_ele_Brow
        pop     ax
        inc     al
        add     si,word ptr ele_size
        pop     cx
        loop    DB1

        mov     ax,Brow_point
        push    ax
        call    Take_brow_addr
        pop     ax
        sub     ax,Brow_Top
        inc     ax
        add     al,byte ptr row
        dec     al
        mov     ah,Get_color
        call    disp_ele_Brow
        ret
Disp_Brow   endp

Disp_ele_brow   proc near
        mov     dh,al
        mov     dl,byte ptr col
        push    ds
        push    si
        mov     cx,word ptr ele_size
        mov     bx,word ptr Brow_addr[2]
        mov     ds,bx
        call    WScr
        pop     si
        pop     ds
        ret
Disp_ele_brow   endp

Take_Brow_addr  proc near
        dec     ax
        push    cx
        mov     si,word ptr Brow_addr
        mov     cx,word ptr Ele_size
        mul     cx
        add     si,ax
        pop     cx
        ret
Take_Brow_addr  endp

Code    ends
        end

