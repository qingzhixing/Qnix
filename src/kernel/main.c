#include <qnix/qnix.h>
#include <qnix/console.h>
#include <qnix/string.h>

char message[] = "Hello Qnix Console!\n";
void KernelInit() {
    ConsoleInit();
    for(int i=1;i<=30;i++){
        ConsoleWrite(message,strlen(message));
    }
}