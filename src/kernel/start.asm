[bits 32]

extern KernelInit

global _start
_start:
    ; mov byte [0xb8000], 'K'
    call KernelInit
    jmp $