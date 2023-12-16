[bits 32]
section .text; 代码段

; extern uint8_t inb(uint16_t port);
global inb
inb:
    push ebp
    mov ebp, esp; 保存栈帧

    xor eax,eax
    mov edx,[ebp + 8]; port
    in al,dx ; 将 端口号dx 中的数据 其中 8 bit 读入 al

    jmp $+2 ; 延迟

    leave ; 恢复栈帧
    ret

; extern uint16_t inw(uint16_t port);
global inw
inw:
    push ebp
    mov ebp, esp; 保存栈帧

    xor eax,eax
    mov edx,[ebp + 8]; port
    in ax,dx ; 将 端口号dx 中的数据 其中 16 bit 读入 ax

    jmp $+2 ; 延迟

    leave ; 恢复栈帧
    ret

; extern void outb(uint16_t port,uint8_t value);
global outb
outb:
    push ebp
    mov ebp, esp; 保存栈帧

    mov edx,[ebp + 8]; port
    mov eax,[ebp + 12]; value

    out dx,al ; 将 8 bit 数据 al 写入 端口号 dx

    jmp $+2 ; 延迟

    leave ; 恢复栈帧
    ret

; extern void outw(uint16_t port,uint8_t value);
global outw
outw:
    push ebp
    mov ebp, esp; 保存栈帧

    mov edx,[ebp + 8]; port
    mov eax,[ebp + 12]; value

    out dx,ax ; 将 16 bit 数据 ax 写入 端口号 dx

    jmp $+2 ; 延迟

    leave ; 恢复栈帧
    ret