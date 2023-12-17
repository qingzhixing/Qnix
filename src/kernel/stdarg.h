#ifndef QNIX_STDARG_H
#define QNIX_STDARG_H
#include <qnix/types.h>

typedef uint8_t* va_list;

#define va_start(ap,v) (ap = (va_list)&v + sizeof(va_list))
#define va_arg(ap,type) (*(type*)((ap += sizeof(va_list)) - sizeof(va_list)))
#define va_end(ap) (ap = (va_list)0)
#endif //QNIX_STDARG_H
