BUILD := ../build
SRC := .


$(BUILD)/boot/%.bin: $(SRC)/boot/%.asm
	$(shell mkdir -p $(dir $@))
	nasm -f bin $< -o $@

LOADER_SECTOR_LBA = 2
LOADER_SECTOR_COUNT = 4
$(BUILD)/master.img:\
		$(BUILD)/boot/boot.bin\
		$(BUILD)/boot/loader.bin
	yes | bximage -q -hd=16M -mode=create -sectsize=512 -imgmode=flat $@
	dd if=$(BUILD)/boot/boot.bin of=$@ bs=512 count=1 conv=notrunc
	dd if=$(BUILD)/boot/loader.bin of=$@ bs=512 count=$(LOADER_SECTOR_COUNT) seek=$(LOADER_SECTOR_LBA) conv=notrunc

.PHONY: test
test:$(BUILD)/boot/loader.bin

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