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

    ; 结构体数量
    mov cx, [ards_count]
    ; 结构体指针
    mov si, 0

.show:
    mov eax, [si+ards_buffer]
    mov ebx, [si+ards_buffer+8]
    mov edx, [si+ards_buffer+16]
    add si,20
    loop .show
; 阻塞
jmp $

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

ards_count: 
    dw 0

ards_buffer:
