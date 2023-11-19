[org 0x7c00]

; 清屏 
mov ax, 3
int 0x10

; 初始化段寄存器
mov ax,0
mov ds,ax
mov es,ax
mov ss,ax
; 初始化栈指针
mov sp,0x7c00

xchg bx,bx

; 打印booting
; si:变址寄存器
mov si,booting
call print

; 阻塞
jmp $

print:
    mov ah,0x0e
    .loop:
        mov al,[si]
        cmp al,0
        je .done

        int 0x10
        inc si
        
        jmp .loop
    .done:
        ret

booting:
    ; 10,13,0 : \n \r \0
    db "Booting Qnix...",10,13,0

; 填充 0 到510字节
; $ 当前行字节偏移
; $$ 代码开始的字节偏移
times 510-($-$$) db 0

; 魔数通过主引导扇区校验
; dw 0xaa55
db 0x55,0xaa