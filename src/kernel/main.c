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
    uint8_t data = inb(CRT_DATA_REG);
}