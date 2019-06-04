code    segment public
        assume  cs: code, ds: code
        public  CMFinit, CMFplay, CMFstop, CMFGoon, CMFPause
;-------------------------------------------------------------------------------
; Return false if not OK
; Function CMFinit(CmfStatus: Pointer): Boolean;
;-------------------------------------------------------------------------------
CMFinit proc    far
        push    bp
        mov     bp, sp
        push    ds
        push    es

        mov     ax, cs
        mov     ds, ax
        xor     ax, ax
        mov     es, ax
        mov     di, 080h
        shl     di, 1
        shl     di, 1
        mov     ax, word ptr es:[di+2]          ; segment
        mov     di, 0103h
        mov     es, ax
        lea     si, CMF
        CLD
        mov     cx, 5
        repe    cmpsb
        or      cx, cx
        je      OK                              ; Driver found
        mov     ax, 0
        jmp     CMFI
OK:
        mov     bx, 08h                         ; Initialize
        int     080h

        mov     bx, 01                          ; set status byte
        mov     ax, word ptr ss:[bp+6]
        mov     dx, word ptr ss:[bp+8]
        int     080h
        mov     ax, 1
CMFI:
        pop     es
        pop     ds
        pop     bp
        ret
CMFinit endp
;-------------------------------------------------------------------------------
; Procedure  CMFplay(Databuf: Pointer)
;-------------------------------------------------------------------------------
CMFplay proc    far
        push    bp
        mov     bp, sp
        push    es

        les     di, dword ptr ss:[bp+6]
        mov     ax, word ptr es:[di+6]
        add     ax, di
        mov     dx, es
        mov     cx, 18                          ; instrument number
        mov     bx, 02
        int     080h

        les     di, dword ptr ss:[bp+6]
        mov     cx, word ptr es:[di+0ch]
        mov     ax, 034e5h
        mov     dx, 012h
        div     cx
        mov     bx, 04
        int     080h

;       mov     bx, 11                          ; set user function
;       mov     dx, word ptr ss:[bp+10]
;       mov     ax, word ptr es:[bp+12]
;       int     080h

        les     di, dword ptr ss:[bp+6]
        mov     ax, word ptr es:[di+8]
        add     ax, di
        mov     dx, es
        mov     bx, 06                          ; Playback
        int     080h

        pop     es
        pop     bp
        ret
CMFplay endp

;-------------------------------------------------------------------------------
; Stop CMF playing
;-------------------------------------------------------------------------------
CMFstop proc    far
;       mov     bx, 9
;       int     080h
        mov     bx, 7
        int     080h
        ret
CMFstop endp

;-------------------------------------------------------------------------------
; CMF pause
;-------------------------------------------------------------------------------
CMFpause proc    far
        mov     bx, 9
        int     080h
        ret
CMFpause endp

;-------------------------------------------------------------------------------
; CMF continue
;-------------------------------------------------------------------------------
CMFGoon proc    far
        mov     bx, 10
        int     080h
        ret
CMFgoon endp

cmf     db      'FMDRV'

code    ends
        end
