#include <qnix/qnix.h>
#include <qnix/console.h>
#include <qnix/string.h>
#include <qnix/stdarg.h>

void TestArgs(int cnt,...){
    va_list args;
    va_start(args,cnt);

    int arg;
    while(cnt--){
        arg= va_arg(args,int);
    }
    va_end(args);
}

char message[] = "Hello Qnix\t Console!\n";
void KernelInit() {
    ConsoleInit();
    TestArgs(5,1,0x55,0xaa,5,10);
}