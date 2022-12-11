%.bin: %.asm
	nasm -f bin $< -o $@


master.img: boot.bin loader.bin
	yes | bximage -q -hd=16 -mode=create -sectsize=512 -imgmode=flat master.img
	dd if=boot.bin of=master.img bs=512 count=1 conv=notrunc 
	dd if=loader.bin conv=notrunc of=master.img bs=512 count=4 seek=2 conv=notrunc 

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
	make loader.bin
	make master.img
	make bochs