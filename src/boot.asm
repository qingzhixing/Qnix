[org 0x7c00]    ; 代码在内存中的位置为0x7c00

; 设置屏幕模式为文本模式，清除屏幕
mov ax,3
int 0x10

; 初始化段寄存器
mov ax,0
mov ds,ax
mov es,ax
mov ss,ax
mov sp,0x7c00

xchg bx,bx          ;bochs魔术断点

mov si,booting
call print

; 0xb8000 为文本显示器内存区域
;mov ax,0xb800
;mov ds,ax
;mov byte [0], 'Q'
;mov byte [2], 'Z'
;mov byte [4], 'X'

print:
    mov ah,0x0e
.next:
    mov al,[si]
    cmp al,0
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret

booting:
    db "Booting Qnix...", 10, 13, 0 ;\n\r\0

; 阻塞
jmp $

; 填充0
times 510-($-$$) db 0

; 主引导扇区最后两个字节必须是0x55,0xaa
; da0xaa55
db 0x55,0xaa