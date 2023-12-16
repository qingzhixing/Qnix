#include <qnix/qnix.h>
#include <qnix/string.h>

void KernelInit() {
    char hello[10] = "HELLO";
    char world[10] = " WORLD";
    char buffer[1000];
    strcpy(buffer,hello);
    strcat(buffer,world);
    
    char * video = (char*)(0xb8000);
    for(size_t i = 0; i < strlen(buffer); i++) {
        video[i*2] = buffer[i];
    }
}