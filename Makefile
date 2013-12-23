DEV=/dev/sdb

boot: boot.s
	nasm boot.s -o boot.bin
	dd if=boot.bin of=$(DEV)

kernel: kernel.s
	nasm kernel.s -o kernel.bin
	dd if=kernel.bin of=$(DEV) obs=64K ibs=64K seek=1

run: boot kernel
	qemu -m 1M $(DEV)

