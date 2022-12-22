BUILD:=../build
SRC:=.

ENTRYPOINT:=0x10000

$(BUILD)/boot/%.bin: $(SRC)/boot/%.asm
	$(shell mkdir -p $(BUILD)/boot)
	nasm -f bin $< -o $@

$(BUILD)/kernel/%.o: $(SRC)/kernel/%.asm
	$(shell mkdir -p $(BUILD)/kernel)
	nasm -f elf32 $< -o $@

$(BUILD)/kernel.bin: $(BUILD)/kernel/start.o 
	ld -m elf_i386 -static $^ -o $@ -Ttext $(ENTRYPOINT)

$(BUILD)/master.img: $(BUILD)/boot/boot.bin \
	$(BUILD)/boot/loader.bin

	yes | bximage -q -hd=16 -mode=create -sectsize=512 -imgmode=flat $@
	dd if=$(BUILD)/boot/boot.bin of=$@ bs=512 count=1 conv=notrunc 
	dd if=$(BUILD)/boot/loader.bin conv=notrunc of=$@ bs=512 count=4 seek=2 conv=notrunc 

.PHONY: clean 
clean:
	rm -rf $(BUILD)

.PHONY: bochs
bochs: $(BUILD)/master.img
	bochs -q 

test: $(BUILD)/kernel.bin