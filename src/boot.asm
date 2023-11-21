[org 0x7c00]

InitializeRegister:
    ; 初始化段寄存器
    mov ax,0
    mov ds,ax
    mov es,ax
    mov ss,ax
    ; 初始化栈指针
    mov sp,0x7c00

; 清屏 
mov ax, 3
int 0x10

; 打印booting
; si:变址寄存器
mov si,booting
call Print

call BochsMagicBreak

; 读取loader到内存
; 0x5XX ~ 0x7c00是计算机的OS Load Area
; 内存分布: https://www.ruanyifeng.com/blog/2015/09/0x7c00.html
mov edi,0x1000
mov ecx,0
mov bl,1
call ReadDisk

call BochsMagicBreak

; 阻塞
jmp $

; 打印字符串
; 调用方法: 将字符串地址存入 si
Print:
    mov ah,0x0e
    .Loop:
        mov al,[si]
        cmp al,0
        je .Done

        int 0x10
        inc si
        
        jmp .Loop
    .Done:
        ret

BochsMagicBreak:
    xchg bx,bx
    ret

; 读取磁盘
; 初始化操作:
;   edi: 读取到的对应内存
;   ecx: 读取的起始扇区(LBA28模式)
;   bl: 读取的扇区数
ReadDisk:
    ;0x1F2：读写扇区的数量
    mov dx,0x1f2
    mov al,bl
    out dx,al

    ;0x1F3：读写扇区起始地址0~7位
    mov dx,0x1f3
    mov al,cl
    out dx,al

    ;0x1F4：读写扇区起始地址8~15位
    mov dx,0x1f4
    shr ecx,8
    mov al,cl
    out dx,al

    ;0x1F5：读写扇区起始地址16~23位
    mov dx,0x1f5
    shr ecx,8
    mov al,cl
    out dx,al

    ;0x1F6：Device寄存器
    ;   0 ~ 3：起始扇区的 24 ~ 27 位
    ;   4: 0 主盘, 1 从片
    ;   6: 0 CHS, 1 LBA
    ;   5 ~ 7：固定为1
    mov dx,0x1f6
    shr ecx,8
    ; 取最开始3bit
    and cl,0b111;
    mov al,cl
    or al,0b1110_0000   ; 主盘 LBA模式
    out dx,al

    ;0x1F7：out时:Command寄存器
    mov dx,0x1f7
    mov al,0x20         ; 读硬盘
    out dx,al

    ; 清空
    xor ecx,ecx
    ; 得到读写扇区的数量
    mov cl,bl

    ; 读取硬盘

    ; 等待数据准备完毕
    ; 0x1F7: in时，作为Status寄存器
    mov dx,0x1f7
    .CheckStatus:
        in al,dx
        jmp $+2
        jmp $+2     ; 直接跳转到下一行，用于产生延迟
        jmp $+2     ; 产生的延迟比nop多

        and al,0b1000_1000
        cmp al,0b0000_1000
        ; 第七位为0，第三位为1则准备完毕:
        ;    0 ERR
        ;    3 DRQ 数据准备完毕
        ;    7 BSY 硬盘繁忙
        ; 否则继续等待
        jne .CheckStatus

    ; 循环读取
    .ReadOneBlock:
        ; 备份ecx
        push ecx

        ; 0x1F0: Data寄存器
        mov dx,0x1f0
        mov cx,256; 一个扇区256字(512Byte)
        .ReadDW:
            in ax,dx
            jmp $+2
            jmp $+2     ; 直接跳转到下一行，用于产生延迟
            jmp $+2     ; 产生的延迟比nop多
            mov [edi],ax
            add edi,2
            loop .ReadDW
        
        ; 读取结束，恢复ecx
        pop ecx
        loop .ReadOneBlock

    ret

    

booting:
    ; 10,13,0 : \n \r \0
    db "Booting Qnix...",10,13,0

FillSector:
    ; 填充 0 到 510字节
    ; $ 当前行字节偏移
    ; $$ 代码开始的字节偏移
    times 510-($-$$) db 0

    ; 魔数通过主引导扇区校验
    ; dw 0xaa55
    db 0x55,0xaa