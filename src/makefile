%.bin:%.asm
	nasm -f bin $< -o $@

LOADER_SECTOR_LBA = 2
LOADER_SECTOR_COUNT = 4
master.img:boot.bin loader.bin
	yes | bximage -q -hd=16M -mode=create -sectsize=512 -imgmode=flat master.img
	dd if=boot.bin of=master.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=master.img bs=512 count=$(LOADER_SECTOR_COUNT) seek=$(LOADER_SECTOR_LBA) conv=notrunc

.PHONY: clean
clean:
	rm -f *.bin
	rm -f *.img

.PHONY: build
build:master.img

.PHONY: bochs
bochs:build
	bochs -q -f bochsrc

# 这里需要更改格式化的硬盘！！
USB_DEVICE = /dev/sdb
.PHONY:usb
usb:boot.bin $(USB_DEVICE)
# 读取主引导扇区
	sudo dd if=$(USB_DEVICE) of=temp.bin bs=512 count=1 conv=notrunc
# 转移数据来避免无权限编辑
	cp temp.bin usb.bin
	sudo rm temp.bin
# 写MBR，但是不覆盖主引导扇区，所以只复制446字节
	dd if=boot.bin of=usb.bin bs=446 count=1 conv=notrunc
# 回写
	sudo sudo dd if=usb.bin of=$(USB_DEVICE) bs=512 count=1 conv=notrunc

	lsblk
