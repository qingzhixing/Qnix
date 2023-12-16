BUILD = ../build
SRC = .

CFLAGS = -m32 # 32位程序
CFLAGS += -fno-builtin # 不需要gcc内置函数 (如memcpy)
CFLAGS += -nostdinc # 不需要标准头文件
CFLAGS += -fno-pic # 不需要位置无关的代码
CFLAGS += -fno-pie # 不需要位置无关的可执行程序
CFLAGS += -nostdlib # 不需要标准库
CFLAGS += -fno-stack-protector # 不需要栈保护
CFLAGS := $(strip $(CFLAGS))

DEBUG = -g
INCLUDE = -I $(SRC)/include


$(BUILD)/boot/%.bin: $(SRC)/boot/%.asm
	$(shell mkdir -p $(dir $@))
	nasm -f bin $< -o $@

$(BUILD)/kernel/%.o: $(SRC)/kernel/%.asm
	$(shell mkdir -p $(dir $@))
	nasm -f elf32 $(DEBUG) $< -o $@
	
$(BUILD)/kernel/%.o: $(SRC)/kernel/%.c
	$(shell mkdir -p $(dir $@))
	gcc $(CFLAGS) $(DEBUG) $(INCLUDE) -c $< -o $@

# 链接
ENTRYPOINT = 0x10000
$(BUILD)/kernel.bin: \
		$(BUILD)/kernel/start.o\
		$(BUILD)/kernel/main.o\
		$(BUILD)/kernel/io.o
	$(shell mkdir -p $(dir $@))
	ld -m elf_i386 -static $^ -o $@ -Ttext $(ENTRYPOINT)

# 省去对elf文件处理步骤，直接跳转运行即可
# 所有的标号和可重定位信息都会被去掉
$(BUILD)/system.bin: $(BUILD)/kernel.bin
	objcopy -O binary $< $@

# 符号表
$(BUILD)/system.map: $(BUILD)/kernel.bin
	nm $< | sort > $@

$(BUILD)/master.img:\
		$(BUILD)/boot/boot.bin\
		$(BUILD)/boot/loader.bin\
		$(BUILD)/system.bin\
		$(BUILD)/system.map
	yes | bximage -q -hd=16M -mode=create -sectsize=512 -imgmode=flat $@
	dd if=$(BUILD)/boot/boot.bin of=$@ bs=512 count=1 conv=notrunc
	dd if=$(BUILD)/boot/loader.bin of=$@ bs=512 count=4 seek=2 conv=notrunc
# 内核大小约100k(200扇区)
	dd if=$(BUILD)/system.bin of=$@ bs=512 count=200 seek=10 conv=notrunc


.PHONY: test
test:$(BUILD)/kernel.bin

.PHONY: clean
clean:
	rm -rf $(BUILD)

.PHONY: build
build:$(BUILD)/master.img

.PHONY: qemu
qemu:$(BUILD)/master.img
# -boot c指第一个硬盘,ab为软盘,d位CD-ROM
	qemu-system-i386 \
	-m 32M \
	-boot c \
	-hda $<

.PHONY: qemu-gdb
qemu-gdb:$(BUILD)/master.img
# -boot c指第一个硬盘,ab为软盘,d位CD-ROM
	qemu-system-i386 \
	-m 32M \
	-s -S \
	-boot c \
	-hda $<

.PHONY: bochs
bochs:$(BUILD)/master.img
	bochs -q -f bochsrc

.PHONY: bochs-gdb
bochs-gdb:$(BUILD)/master.img
	rm -f $(BUILD)/*.lock
	../bochs/bin/bochs -q -f bochsrc.gdb

.PHONY: bochs_usb
bochs_usb:
	bochs -q -f bochsrc_usb

# 这里需要更改格式化的硬盘！！
USB_DEVICE = /dev/sdb
MAX_LOADER_BLOCK_USE = 300
.PHONY:usb_boot
usb_boot:$(BUILD)/master.img $(USB_DEVICE)
# 处理主引导扇区
	sudo dd if=$(USB_DEVICE) of=$(BUILD)/temp.bin bs=512 count=1 conv=notrunc
# 转移数据来避免无权限编辑
	cp $(BUILD)/temp.bin $(BUILD)/usb.bin
# 写MBR，但是不覆盖主引导扇区，所以只复制446字节
	dd if=$(BUILD)/boot/boot.bin of=$(BUILD)/usb.bin bs=446 count=1 conv=notrunc
# 将master.img第一扇区替换为usb.bin(含有分区表)
	dd if=$(BUILD)/usb.bin of=$(BUILD)/master.img bs=512 count=1 conv=notrunc
# 回写
	sudo sudo dd if=$(BUILD)/master.img of=$(USB_DEVICE) bs=512 count=$(MAX_LOADER_BLOCK_USE) conv=notrunc

	lsblk 

$(BUILD)/master.vmdk: $(BUILD)/master.img
	qemu-img convert -O vmdk $< $@

.PHONY:vmdk
vmdk:$(BUILD)/master.vmdk