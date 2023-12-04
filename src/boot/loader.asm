; Loader Const
LOADER_BASE_ADDR equ 0x1000

; Kernel Const
KERNEL_BASE_ADDR equ 0x10000
KERNEL_SECTOR_LBA equ 10
KERNEL_SECTOR_COUNT equ 200

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

        mov [totalMemBytes], edx

mov si,preparingProtectModeMessage
call Print

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

preparingProtectModeMessage:
    db "Preparing Protect Mode O_O",10,13,0

PrepareProtectMode:
    cli; 关闭中断

    ; 打开A20总线
    in al,0x92
    or al,0b10; 第二位置为1
    out 0x92,al

    ; 加载 GDT
    lgdt [gdtPtr]

    ; 打开保护模式
    mov eax,cr0
    or eax,1
    mov cr0,eax

    ; jmp $

    ; 刷新cpu流水线
    jmp dword codeSelector:StartProtectMode

[bits 32]
StartProtectMode:
    ; 初始化段寄存器
    mov ax,dataSelector
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax
    mov ss,ax

    ; 初始化栈
    mov esp,0x10000 ; 之后内核加载到的地址(0x7e00~0x9fb00都可用)

    mov byte [0xb8000], 'Q'
    mov byte [0x200000], 'Q' ; 尝试修改2M处地址

    ; 读取kernel
    mov edi,KERNEL_BASE_ADDR
    mov ecx,KERNEL_SECTOR_LBA
    mov bl,KERNEL_SECTOR_COUNT
    call ReadDisk

    ; 跳转到kernel
    jmp codeSelector:KERNEL_BASE_ADDR

    ud2 ; 表示出错，事实上我们不可能执行到这个地方

    jmp $ ; 阻塞

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

    ;0x1F6：Device寄存器:
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

        ; 判断是否产生错误
        push dx
        mov dx,ax
        and dl,0b0000_0001
        cmp dl,0b0000_0001
        pop dx
        
        jne .Else
        call .ShowErrorMsg

        .Else:

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
            mov [edi],ax
            add edi,2
            loop .ReadDW
        
        ; 读取结束，恢复ecx
        pop ecx
        loop .ReadOneBlock

    ret
    .ShowErrorMsg:
        mov si,diskErrorMsg
        call Print
        ret

diskErrorMsg:
    db "Disk Error Occured :(",10,13,0

; Selector:
; RPL: 00,TI:0 全局描述符,index:GDT1
codeSelector equ (1<<3)
; RPL: 00,TI:1 全局描述符,index:GDT2
dataSelector equ (2<<3)

; GDT Const
memoryBase equ 0        ; 内存开始的地址，基地址
granulary equ 1         ; 内存粒度:4K
; 内存界限: 4G / 4K -1
memoryLimit equ ((4*1024*1024*1024)/(4*1024))-1

gdtPtr:
    dw (gdtEnd-gdtBase)-1; gdt长度
    dd gdtBase; gdt地址

; 存放gdt数组(每个8字节)
gdtBase:
    ; GDT0: 全0,NULL
    dd 0,0
gdtCode:
    ; GDT1: 代码段
    dw memoryLimit & 0xffff; 段界限 0~15位
    dw memoryBase & 0xffff; 段基地址 0~15位
    db (memoryBase >> 16) & 0xff; 段基地址 16~23位
    ; 存在内存中 - dpl0 - 用户段 - 代码段:非依从 - 可读 - 未被访问
    db 0b_1_00_1_1010
    ; 4K粒度，32位，非64位，Avalable随便写，段界限16~19位
    db 0b_1_1_0_0_0000 | (memoryLimit >> 16) & 0xf
    db (memoryBase >> 24) & 0xff; 段基地址 24~31位
gdtData:
    ; GDT2: 数据段
    dw memoryLimit & 0xffff; 段界限 0~15位
    dw memoryBase & 0xffff; 段基地址 0~15位
    db (memoryBase >> 16) & 0xff; 段基地址 16~23位
    ; 存在内存中 - dpl0 - 用户段 - 数据段:向上扩展 - 可写 - 未被访问
    db 0b_1_00_1_0010
    ; 4K粒度，32位，非64位，Avalable随便写，段界限16~19位
    db 0b_1_1_0_0_0000 | (memoryLimit >> 16) & 0xf
    db (memoryBase >> 24) & 0xff; 段基地址 24~31位
gdtEnd:

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
