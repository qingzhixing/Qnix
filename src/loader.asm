[org 0x1000]

dw 0xaa55   ; 用于判断是否加载成功

mov si,loaderMessage
call Print

jmp $       ; 阻塞

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

loaderMessage:
    dd "Loaded into loader!^_^",10,13,0