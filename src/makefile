boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin 

master.img: boot.bin
	yes | bximage -q -hd=16 -mode=create -sectsize=512 -imgmode=flat master.img
	dd if=boot.bin conv=notrunc of=master.img bs=512 count=1

.PHONY: clean 
clean:
	rm -rf *.bin 
	rm -rf *.img

.PHONY: bochs
bochs: 
	bochs -q 

compile_run: boot.asm
	make clean
	make boot.bin
	make master.img
	make bochs