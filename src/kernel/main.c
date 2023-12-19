#include <qnix/qnix.h>
#include <qnix/console.h>
#include <qnix/assert.h>

void KernelInit() {
    ConsoleInit();
    assert(1>2);
    return;
}