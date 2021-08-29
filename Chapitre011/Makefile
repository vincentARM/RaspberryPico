ARMGNU ?= E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi


AOPS = --warn --fatal-warnings -mcpu=cortex-m0
COPS = -Wall -O2 -ffreestanding -mcpu=cortex-m0
LOPS = -nostdlib -nostartfiles

all : blinkA11.uf2

clean:
	rm -f *.bin
	rm -f *.o
	rm -f *.elf
	rm -f *.list
	rm -f *.uf2

blinkA11.uf2: blinkA11.bin
	python uf2conv.py --family 0xE48BFF56 --base 0x10000000  blinkA11.bin -o blinkA11.uf2
    
blinkA11.o : blinkA11.s
	$(ARMGNU)-as $(AOPS)  blinkA11.s -o blinkA11.o

blinkA11.bin :               memmap.ld blinkA11.o
	$(ARMGNU)-ld  -T memmap.ld  blinkA11.o -o blinkA11.elf
	$(ARMGNU)-objdump -D blinkA11.elf > blinkA11.list
	$(ARMGNU)-objcopy -O binary blinkA11.elf blinkA11_dep.bin
	python pad_checksum_binary.py -p256 -s-1 blinkA11_dep.bin blinkA11.bin
