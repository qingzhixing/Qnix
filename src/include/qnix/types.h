#ifndef QNIX_TYPES_H
#define QNIX_TYPES_H

#include "stdint.h"

#define EOF -1

#define NULL 0
#define nullptr NULL

#define bool _Bool
#define true 1
#define false 0

// 用于定义特殊的结构体
#define _packed __attribute__((packed))

typedef unsigned int size_t;

#endif //QNIX_TYPES_H
