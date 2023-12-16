#ifndef QNIX_IO_H
#define QNIX_IO_H
#include <qnix/types.h>
extern uint8_t inb(uint16_t port); // 输入一个字节
extern uint16_t inw(uint16_t port); // 输入一个字

extern void outb(uint16_t port,uint8_t value); // 输出一个字节
extern void outw(uint16_t port,uint16_t value); // 输出一个字
#endif //QNIX_IO_H
