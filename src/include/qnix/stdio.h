#ifndef QNIX_STDIO_H
#define QNIX_STDIO_H

#include <qnix/stdarg.h>

// 返回buffer中需要输出的字符数量
int vsprintf(char * buffer,const char * format,va_list args);
// 返回buffer中需要输出的字符数量
int sprintf(char * buffer,const char * format,...);
#endif //QNIX_STDIO_H
