#ifndef QNIX_CONSOLE_H
#define QNIX_CONSOLE_H
#include <qnix/types.h>

void ConsoleInit();
void ConsoleClear();
void ConsoleWrite(char* buf,uint32_t count);
#endif //QNIX_CONSOLE_H
