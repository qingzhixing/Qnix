.PHONY: clean
clean:
	rm -f *.bin
	rm -f *.img
	rm -f *.ini

.PHONY: bochs
bochs:
	nasm -f bin boot.asm -o boot.bin
	bximage -q -hd=16M -mode=create -sectsize=512 -imgmode=flat master.img
	dd if=boot.bin of=master.img bs=512 count=1 conv=notrunc
	bochs -q -f bochsrc