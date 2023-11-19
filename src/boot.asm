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

; 初始化屏幕
mov ax,0xb800
mov ds,ax
; 此时ds指向显存段基址
; 显存地址: 0xB800 ~ 0xBFFFF

; 将屏幕第一个字符初始化为'H'
mov byte [0x00], 'H'

; 阻塞
jmp $

; 填充 0 到510字节
; $ 当前行字节偏移
; $$ 代码开始的字节偏移
times 510-($-$$) db 0

; 魔数通过主引导扇区校验
; dw 0xaa55
db 0x55,0xaa