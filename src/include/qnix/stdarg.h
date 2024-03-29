#ifndef QNIX_STDARG_H
#define QNIX_STDARG_H
#include <qnix/types.h>

typedef uint8_t* va_list;

// 先将指针移动到参数所在内存再赋值
// 加法是因为栈从高往低扩展，
#define va_start(ap,v) (ap = (va_list)&v + sizeof(va_list))
// 边移动边取值
#define va_arg(ap,type) (*(type*)((ap += sizeof(va_list)) - sizeof(va_list)))
#define va_end(ap) (ap = (va_list)0)
#endif //QNIX_STDARG_H
