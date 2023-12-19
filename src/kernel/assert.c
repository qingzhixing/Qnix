#include <qnix/assert.h>
#include <qnix/printk.h>
#include <qnix/stdio.h>
#include <qnix/types.h>

static uint8_t buffer[1024];

// 强制阻塞
static void spin(char * name){
    printk("Spining in %s ...\n",name);
    while(true);
}
void assertion_failure(char* exp, char* file, char * base,const char * func, int line){
    printk(
        "Assertion failed: %s\n"
        "File: %s\n"
        "Base: %s\n"
        "Function: %s\n"
        "Line: %d\n",
        exp,file,base,func,line
    );
    spin("assertion_failure()");

    // 不可能走到这里，否则发送报错
    asm volatile("ud2");
}

void panic(const char* fmt,...){
    va_list args;
    va_start(args,fmt);
    int i = vsprintf(buffer,fmt,args);
    va_end(args);

    printk("!!!  PANIC  !!!\n%s \n",buffer);
    spin("panic()");
    
    // 不可能走到这里，否则发送报错
    asm volatile("ud2");
}