#include <qnix/console.h>
#include <qnix/io.h>

#define CRT_ADDR_REG 0x3D4 // CRT(6845)索引寄存器
#define CRT_DATA_REG 0x3D5 // CRT(6845)数据寄存器

#define CRT_START_ADDR_H 0xC // 显示内存起始位置 - 高位
#define CRT_START_ADDR_L 0xD // 显示内存起始位置 - 低位
#define CRT_CURSOR_H 0xE     // 光标位置 - 高位
#define CRT_CURSOR_L 0xF     // 光标位置 - 低位

#define MEM_BASE 0xB8000              // 显卡内存起始位置
#define MEM_SIZE 0x4000               // 显卡内存大小
#define MEM_END (MEM_BASE + MEM_SIZE) // 显卡内存结束位置
#define WIDTH 80                      // 屏幕文本列数
#define HEIGHT 25                     // 屏幕文本行数
#define ROW_SIZE (WIDTH * 2)          // 每行字节数
#define SCR_SIZE (ROW_SIZE * HEIGHT)  // 屏幕字节数

#define NUL 0x00
#define ENQ 0x05
#define ESC 0x1B // ESC
#define BEL 0x07 // \a
#define BS 0x08  // \b
#define HT 0x09  // \t
#define LF 0x0A  // \n
#define VT 0x0B  // \v
#define FF 0x0C  // \f
#define CR 0x0D  // \r
#define DEL 0x7F

// 记录当前显示器开始的内存地址
static uint32_t screenDisplayBase;

// 当前光标的内存位置
static uint32_t cursorMemPosition;

// 当前光标的坐标
static uint32_t cursorX,cursorY;

// 字符样式
static uint8_t attribute = 7;
static uint16_t erase = 0x0720; // 空格

// 从硬件获取当前显示器开始的位置
static void InScreenDisplayBase(){
    outb(CRT_ADDR_REG,CRT_START_ADDR_H);
    screenDisplayBase = inb(CRT_DATA_REG) << 8;
    outb(CRT_ADDR_REG,CRT_START_ADDR_L);
    screenDisplayBase |= inb(CRT_DATA_REG);

    screenDisplayBase <<= 1; // screenDisplayBase *=2
    screenDisplayBase += MEM_BASE;
}

// 输出当前显示器开始的位置到硬件 
static void OutScreenDisplayBase(){
    outb(CRT_ADDR_REG,CRT_START_ADDR_H);
    outb(CRT_DATA_REG,(uint8_t)((screenDisplayBase-MEM_BASE) >> 1 >> 8 ));
    outb(CRT_ADDR_REG,CRT_START_ADDR_L);
    outb(CRT_DATA_REG,(uint8_t)( ((screenDisplayBase-MEM_BASE) >>1) & 0xFF));
}

// 从硬件获取光标在内存中的地址
static void InCursor(){
    outb(CRT_ADDR_REG,CRT_CURSOR_H);
    cursorMemPosition = inb(CRT_DATA_REG) << 8;
    outb(CRT_ADDR_REG,CRT_CURSOR_L);
    cursorMemPosition |= inb(CRT_DATA_REG);

    cursorMemPosition<<=1; // *=2
    cursorMemPosition += MEM_BASE;

    InScreenDisplayBase();

    uint32_t delta = (cursorMemPosition - screenDisplayBase) >> 1;
    cursorX = delta % WIDTH;
    cursorY = delta / WIDTH;
}

// 将光标在内存中的位置输出到硬件
static void OutCursor(){
    outb(CRT_ADDR_REG,CRT_CURSOR_H);
    outb(CRT_DATA_REG,(uint8_t)((cursorMemPosition-MEM_BASE) >>1 >> 8 ));
    outb(CRT_ADDR_REG,CRT_CURSOR_L);
    outb(CRT_DATA_REG,(uint8_t)(((cursorMemPosition-MEM_BASE) >>1) &0xFF ));
}

// 用显示器x,y坐标设置光标并输出到硬件
static void SetCursor(uint32_t x,uint32_t y){
    cursorX = x;
    cursorY = y;
    uint32_t delta = (y * WIDTH + x) << 1;
    cursorMemPosition = screenDisplayBase + delta;
    OutCursor();
}

void ConsoleClear(){
    screenDisplayBase = MEM_BASE;
    SetCursor(0,0);
    OutScreenDisplayBase();

    uint16_t * video = (uint16_t *)screenDisplayBase;
    for(uint32_t i = 0; i < (HEIGHT * WIDTH); i++){
        *video++ = erase;
    }
}

void ConsoleInit(){
    ConsoleClear();
}
void ConsoleWrite(char* buf,uint32_t count);