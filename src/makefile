boot.bin:boot.asm
	nasm -f bin boot.asm -o boot.bin

master.img:boot.bin
	yes | bximage -q -hd=16M -mode=create -sectsize=512 -imgmode=flat master.img
	dd if=boot.bin of=master.img bs=512 count=1 conv=notrunc


.PHONY: clean
clean:
	rm -f *.bin
	rm -f *.img

.PHONY: bochs
bochs:master.img
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
