#include <qnix/qnix.h>
#include <qnix/console.h>
#include <qnix/string.h>

char message[] = "Hello Qnix\t Console!\n";
void KernelInit() {
    ConsoleInit();
    while(true){
        ConsoleWrite(message,strlen(message));
    }
}