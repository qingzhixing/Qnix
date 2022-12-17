[org 0x1000]

dw 0x55aa; 魔数，用于判断错误

; 打印字符串
mov si,loading
call print

detect_memory:
    xor ebx,ebx; 将ebx清零

    ; es:di 结构体的缓存位置
    mov ax,0
    mov es,ax
    mov edi,ards_buffer

    mov edx,0x534d4150; 固定签名

.next:
    ; 子功能号
    mov eax,0xe820
    ; ards 结构的大小（字节）
    mov ecx, 20
    ; 调用0x15 系统调用
    int 0x15

    ; 如果CF置位，表示出错
    jc error

    ; 将缓存指针指向下一个结构体
    add di,cx;

    ; 将结构体数量加一
    inc dword [ards_count]

    ; 判断是否检测结束
    cmp ebx,0
    jnz .next

    mov si,detecting
    call print

    jmp prepare_protected_mode

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

loading:
    db "Loading Qnix...", 10, 13, 0 ;\n\r\0

detecting:
    db "Detecting Memory Success...",10 , 13, 0

debug_msg:
    db "Debug Message",10 , 13, 0

error:
    mov si,.msg
    call print
    hlt; 让cpu停止
    jmp $; 阻塞
    .msg db "Loading Qnix Error!!!", 10, 13, 0 

prepare_protected_mode:
    cli ; 关闭中断

    ; 打开A20线
    in al, 0x92
    or al, 0b10
    out 0x92,al

    ; 加载gdt
    lgdt [gdt_ptr]

    ; 启动保护模式
    mov eax,cr0
    or eax,1
    mov cr0,eax

    ; 用跳转刷新缓存,启用保护模式
    jmp dword code_selector:protected_mode

[bits 32]
protected_mode:
    mov ax,data_selector
    ; 初始化段寄存器
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax
    mov ss,ax

    mov esp,0x10000; 修改栈顶 0x7e00~0x9fbff任选一个地址 操作系统加载地址

    mov byte [0xb8000], 'P'

    mov byte [0x200000], 'P'

jmp $; 阻塞

code_selector equ (1 << 3)
data_selector equ (2 << 3)

memory_base equ 0; 内存开始的位置：基地址

; 内存界限:4G/4k-1
memory_limit equ ((1024*1024*1024*4) / (1024*4))-1

gdt_ptr:
    dw (gdt_end-gdt_base)-1
    dd gdt_base
gdt_base:
    dd 0,0; NULL 描述符
gdt_code:
    dw memory_limit & 0xffff; 段界限的0-15位
    dw memory_base & 0xffff; 基地址0-16位
    db (memory_base >> 16) & 0xff; 基地址剩下八位
    ; 存在 - dpl 0 - S _ 代码 - 非依从 - 可读 - 没有被访问过
    db 0b_1_00_1_1_0_1_0 
    ; 4k - 32位 - 不是64位 - 段界限 16~19
    db 0b_1_1_0_0_0000 | (memory_limit>>16) & 0xf
    db (memory_base >> 24) & 0xff
gdt_data:
    dw memory_limit & 0xffff; 段界限的0-15位
    dw memory_base & 0xffff; 基地址0-16位
    db (memory_base >> 16) & 0xff; 基地址剩下八位
    ; 存在 - dpl 0 - S _ 数据 - 向上扩展 - 可写 - 没有被访问过
    db 0b_1_00_1_0_0_1_0 
    ; 4k - 32位 - 不是64位 - 段界限 16~19
    db 0b_1_1_0_0_0000 | (memory_limit>>16) & 0xf
    db (memory_base >> 24) & 0xff

gdt_end:

ards_count: 
    dw 0

ards_buffer:
