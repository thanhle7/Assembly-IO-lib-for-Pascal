
Cur_up          equ  04800h
Cur_down        equ  05000h
Cur_left        equ  04B00h
Cur_right       equ  04D00h
ESC_key         equ  0011Bh
Enter_key       equ  01C0Dh
Home_key        equ  04700h
End_key         equ  04F00h

ele_addr        equ  0     ;        dword
ele_offset      equ  0     ;        word;
ele_segment     equ  2     ;        word;
ele_col         equ  4     ;        byte;
ele_row         equ  5     ;        byte;


Data    segment public

        EXTRN get_color      :  BYTE
        EXTRN color          :  BYTE
        EXTRN row            :  BYTE
        EXTRN col            :  BYTE

        Extrn  PromptBuffer  :  byte
        Extrn  Prompt_point  :  word
        Extrn  Prompt_count  :  word;
        Extrn  Exit_key      :  word
        Extrn  Exit_key1     :  word
        Extrn  Exit_key2     :  word
Data    ends

Code    segment public
        assume  cs:code,ds:data
        Public Prompt,Read_Prompt

        EXTRN   WScr  :  near                   ; IO.ASM

Take_prompt_addr  proc   near
        lea     si,PromptBuffer
        dec     al
        shl     al,1
        push    ax
        shl     al,1
        pop     cx
        add     ax,cx
        add     si,ax
        ret
Take_prompt_addr  endp

Prompt  proc  far
        ; Procedure Prompt(var chuoi : string);
        push    bp
        push    ds
        pop     es
        mov     bp,sp
        inc     word ptr Prompt_count
        mov     ax,word ptr Prompt_count
        call    Take_prompt_addr

        mov     ax,word ptr ss:[bp+6]
        mov     word ptr [si+ele_offset],ax
        mov     ax,word ptr ss:[bp+8]
        mov     word ptr [si+ele_segment],ax

        mov     ah,byte ptr row
        mov     al,byte ptr col
        mov     word ptr [si+ele_col],ax
        pop     bp
        retf    4
Prompt  endp

Disp_prompt  proc  near
        mov     cx,word ptr Prompt_count
        lea     si,PromptBuffer
DP1:
        push    cx
        mov     ah,byte ptr color
        call    disp_ele_prompt
        add     si,6
        pop     cx
        loop    DP1
        mov     ax,word ptr Prompt_point
        call    Take_prompt_addr
        mov     ah,byte ptr get_color
        call    Disp_ele_prompt
        ret
Disp_prompt  endp

Disp_ele_prompt proc near
        mov     dh,byte ptr [si+ele_row]
        mov     dl,byte ptr [si+ele_col]
        push    si
        push    ds
        lds     si,dword ptr [si]
        mov     cx,word ptr [si]
        xor     ch,ch
        inc     si
        call    WScr                            ; IO.ASM
        pop     ds
        pop     si
        ret
Disp_ele_prompt endp

Read_prompt  proc  far
        push    bp
        push    ds
        pop     es
RP0:
        call    Disp_prompt
        or      word ptr Exit_key, 0
        jne     RP1
        jmp     End_read
RP1:
        xor     ax,ax
        int     016h
        mov     word ptr Exit_key, ax           ; The last key pressed

        cmp     ax, word ptr Exit_key1
        je      RP00
        cmp     ax, word ptr Exit_key2
        jne     RP01
RP00:
        jmp     End_read
RP01:
        cmp     ax,Cur_up
        je      RP10
        cmp     ax,cur_left
        jne     RP2
RP10:
        cmp     word ptr Prompt_point,1
        je      RP11
        dec     word ptr Prompt_point
        jmp     short RP0
RP11:
        mov     ax,word ptr Prompt_count
        mov     word ptr Prompt_point,ax
        jmp     short RP0
RP2:
        cmp     ax,Cur_down
        je      RP20
        cmp     ax,Cur_right
        jne     RP3
RP20:
        mov     ax,word ptr Prompt_count
        cmp     word ptr Prompt_point,ax
        je      RP21
        inc     word ptr Prompt_point
        jmp     short RP0
RP21:
        mov     word ptr Prompt_point,1
        jmp     short RP0
RP3:
        cmp     ax,Home_key
        jne     RP4
        mov     word ptr Prompt_point,1
        jmp     short RP0
RP4:
        cmp     ax,End_key
        jne     RP5
        mov     ax,word ptr Prompt_count
        mov     word ptr Prompt_point,ax
        jmp     short RP0
RP5:
        cmp     ax,ESC_key
        jne     RP6
        jmp     short End_read
RP6:
        cmp     ax,Enter_key
        je      End_read
        sub     al, 48
        xor     ah, ah
        cmp     al, 1
        jb      Rp7
        cmp     ax, word ptr prompt_count
        ja      RP7
        mov     prompt_point, ax
        mov     Exit_key, 0
RP7:
        jmp     RP0

End_read:
        mov     Prompt_count, 0
        pop     bp
        ret
Read_prompt     endp

code    ends
        end
