; Loader Const
LOADER_BASE_ADDR equ 0x1000

[org LOADER_BASE_ADDR]

dw 0xaa55   ; 用于判断是否加载成功

mov si,loaderMessage
call Print

;0xe820中断
DetectMemory:
    ; BIOS使用的值 第一次调用时一定要置为0
    xor ebx,ebx

    ; es:di ards结构体存储位置，放在缓冲区里，会有多个
    mov ax,0
    mov es,ax
    mov edi, ardsBuffer

    ; 魔数，用于校验
    mov edx,0x534d4150

    .CheckNext:
        ; 子功能号
        mov eax ,0xe820

        ; ards大小，固定为20Byte
        mov ecx,ARDS_SIZE_BYTES

        ; 调用0x15系统调用
        int 0x15

        ; 检测CF(Carry FLag)位，为1表示出错
        jc ErrorOccur

        ; 将缓存指针指向下一个结构体
        add di,cx

        ; 结构体数量+1
        inc word [ardsCount]

        ; 检测完成ebx会为0,否则继续检测
        cmp ebx,0
        jne .CheckNext

        ; 报告完成
        mov si,detectMemorySuccess
        call Print

    ; edx中存入内存最大值
    .DataHandler:
        ; 结构体数量
        mov cx,[ardsCount]
        ; 结构体偏移，第si个结构体
        mov si,0
        ; 清空最大值
        xor edx,edx

        .FindMaxMemSize:
            ; 在32位模式下不用考虑 BaseAddrHigh 与 LengthHigh
            ; BaseAddrLow
            mov eax,[ardsBuffer + si + 0]
            ; LengthLow
            mov ebx,[ardsBuffer + si + 8]
            
            ; eax = BaseAddrLow + LengthLow = 当前内存段达到的内存最大值
            add eax,ebx

            ; 移动到下一个结构体
            add si,20

            cmp edx,eax         ; edx为最大内存大小

            ; edx大于等于eax则eax不是最大值
            jge .next_ards

            ; 否则更新edx为eax
            mov edx,eax

            .next_ards:
                loop .FindMaxMemSize

        xchg bx,bx
        mov [totalMemBytes], edx

jmp PrepareProtectMode

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

PrepareProtectMode:
    jmp $; TODO: 写到这里停了

; 存放gdt数组(每个8字节)
gdt_base:
    ; GDT0: 全0,NULL
    dd 0,0
    ; GDT1: 代码段
; TODO 继续写GDT

; 总内存容量 32Byte (包括操作系统不可用的内存)
totalMemBytes dd 0

;　ARDS Const
; ARDS结构字节数
ARDS_SIZE_BYTES equ 20
; 内存描述符数量
ardsCount:
    dw 0

; 用于存储内存描述符(不定长)
ardsBuffer:
