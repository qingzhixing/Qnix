#include <qnix/qnix.h>
#include <qnix/console.h>
#include <qnix/string.h>

char message[] = "Hello Qnix Console\b\b!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
void KernelInit() {
    ConsoleInit();
    ConsoleWrite(message,strlen(message));
}