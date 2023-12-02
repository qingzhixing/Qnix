BUILD = ../build
SRC = .


$(BUILD)/boot/%.bin: $(SRC)/boot/%.asm
	$(shell mkdir -p $(dir $@))
	nasm -f bin $< -o $@

$(BUILD)/kernel/%.o: $(SRC)/kernel/%.asm
	$(shell mkdir -p $(dir $@))
	nasm -f elf32 $< -o $@

# 链接
ENTRYPOINT = 0x10000
$(BUILD)/kernel.bin: $(BUILD)/kernel/start.o
	$(shell mkdir -p $(dir $@))
	ld -m elf_i386 -static $< -o $@ -Ttext $(ENTRYPOINT)

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

.PHONY: bochs
bochs:build
	bochs -q -f bochsrc

.PHONY: bochs_usb
bochs_usb:
	bochs -q -f bochsrc_usb

# 这里需要更改格式化的硬盘！！
USB_DEVICE = /dev/sdb

.PHONY:usb_MBR
usb_MBR:$(BUILD)/boot/boot.bin $(USB_DEVICE)
# 读取主引导扇区
	sudo dd if=$(USB_DEVICE) of=temp.bin bs=512 count=1 conv=notrunc
# 转移数据来避免无权限编辑
	cp temp.bin usb.bin
# 写MBR，但是不覆盖主引导扇区，所以只复制446字节
	dd if=boot.bin of=usb.bin bs=446 count=1 conv=notrunc
# 回写
	sudo sudo dd if=usb.bin of=$(USB_DEVICE) bs=512 count=1 conv=notrunc

	lsblk

MAX_LOADER_BLOCK_USE = 10
.PHONY:usb_boot
usb_boot:usb_MBR $(BUILD)/boot/loader.bin $(USB_DEVICE)
	sudo dd if=loader.bin of=$(USB_DEVICE) bs=512 count=$(LOADER_SECTOR_COUNT) seek=$(LOADER_SECTOR_LBA) conv=notrunc
	lsblk