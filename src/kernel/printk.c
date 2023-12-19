#include <qnix/printk.h>
#include <qnix/stdio.h>
#include <qnix/console.h>

static char buffer[1024];

// 返回buffer中输出了的字符数量
int printk(const char *fmt, ...){
    va_list args;
    va_start(args, fmt);

    int amount = vsprintf(buffer, fmt, args);

    va_end(args);

    ConsoleWrite(buffer, amount);

    return amount;
}