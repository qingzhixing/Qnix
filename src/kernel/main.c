#include <qnix/qnix.h>
#include <qnix/console.h>
#include <qnix/string.h>
#include <qnix/stdarg.h>
#include <qnix/printk.h>

char message[] = "Hello Qnix\t Console!\n";
void KernelInit() {
    ConsoleInit();
    int cnt = 30;
    while(cnt--){
        printk("Hello Qnix %#010x\n",cnt);
    }
    return;
}