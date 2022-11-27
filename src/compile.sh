nasm -f bin boot.asm -o boot.bin
dd if=boot.bin conv=notrunc of=master.img bs=512 count=1
bochs -q