#include <qnix/io.h>
#include <qnix/qnix.h>

// CRT 地址寄存器 0x3D4
#define CRT_ADDR_REG 0x3d4
// CRT 数据寄存器 0x3D5
#define CRT_DATA_REG 0x3d5

// CRT 光标位置 - 高位 0xE
#define CRT_CURSOR_HIGH 0xe
// CRT 光标位置 - 低位 0xF
#define CRT_CURSOR_LOW 0xf

void KernelInit() {
    outb(CRT_ADDR_REG, CRT_CURSOR_HIGH);
    uint8_t cursorHigh = inb(CRT_DATA_REG);
    outb(CRT_ADDR_REG, CRT_CURSOR_LOW);
    uint8_t cursorLow = inb(CRT_DATA_REG);
    uint16_t cursorPos=
        (uint16_t)(cursorHigh << 8) |
        (uint16_t)(cursorLow);

    outb(CRT_ADDR_REG,CRT_CURSOR_HIGH);
    outb(CRT_DATA_REG, 0);
    outb(CRT_ADDR_REG,CRT_CURSOR_LOW);
    outb(CRT_DATA_REG, 0);
}