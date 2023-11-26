[org 0x1000]

dw 0xaa55   ; 用于判断是否加载成功

mov si,loaderMessage
call Print

xchg bx,bx

;0xe820中断
DetectMemory:
    ; BIOS使用的值 第一次调用时一定要置为0
    xor ebx,ebx

    ; es:di ards结构体存储位置，放在缓冲区里，会有多个
    mov ax,0
    mov es,ax
    mov edi, ards_buffer

    ; 魔数，用于校验
    mov edx,0x534d4150

    .CheckNext:
        ; 子功能号
        mov eax ,0xe820

        ; ards大小，固定位20Byte
        mov ecx,20

        ; 调用0x15系统调用
        int 0x15

        ; 检测CF(Carry FLag)位，为1表示出错
        jc ErrorOccur

        ; 将缓存指针指向下一个结构体
        add di,cx

        ; 结构体数量+1
        inc word [ards_count]

        ; 检测完成ebx会为0,否则继续检测
        cmp ebx,0
        jne .CheckNext

        ; 报告完成
        mov si,detectMemorySuccess
        call Print

        xchg bx,bx

    .DataHandler:
        ; 结构体数量
        mov cx,[ards_count]
        ; 结构体偏移，第si个结构体
        mov si,0

        .GetData:
            ; 在32位模式下不用考虑 BaseAddrHigh 与 LengthHigh
            ; BaseAddrLow
            mov eax,[ards_buffer + si + 0]
            ; LengthLow
            mov ebx,[ards_buffer + si + 8]
            ; Type
            mov edx,[ards_buffer + si + 16]

            ; 移动到下一个结构体
            add si,20

            xchg bx,bx
            loop .GetData

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
    db "Loaded into loader!^_^",10,13,0

detectMemorySuccess:
    db "Detect Memory Success!",10,13,0

ErrorOccur:
mov si,.msg
call Print
hlt ; CPU停止
jmp $ ; 阻塞
.msg:
    db "Loading Error Occured! :(",10,13,0

; 内存描述符数量
ards_count:
    dw 0

; 用于存储内存描述符(不定长)
ards_buffer:
