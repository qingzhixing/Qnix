#include "../inlucde/qnix/qnix.h"

int magic = QNIX_MAGIC;
char message[] = "Hello Qnix ^~^!"; // .data
char buffer[1024];                  // .bss

void kernel_init() {
    char *video = (char *)0xb8000;
    for (int i = 0; i < sizeof(message); i++) {
        video[i * 2] = message[i];
    }
}