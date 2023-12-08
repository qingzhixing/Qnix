CFLAGS = -m32 # 32位程序
# CFLAGS += -fno-builtin # 不需要gcc内置函数 (如memcpy)
# CFLAGS += -nostdinc # 不需要标准头文件
CFLAGS += -fno-pic # 不需要位置无关的代码
# CFLAGS += -fno-pie # 不需要位置无关的可执行程序
# CFLAGS += -nostdlib # 不需要标准库
# CFLAGS += -fno-stack-protector # 不需要栈保护
CFLAGS += -mpreferred-stack-boundary=2 #去掉栈对齐
CFLAGS += -fomit-frame-pointer #不需要栈帧
CFLAGS += -Qn # 去掉版本信息
CFLAGS += -fno-asynchronous-unwind-tables # 不需要 CFI信息
CFLAGS := $(strip $(CFLAGS))

.PHONY:hello.s
hello.s:hello.c
	gcc -S $(CFLAGS) $< -o $@ 
	chmod 777 *

.PHONY: clean
clean: 
	rm -f *.s