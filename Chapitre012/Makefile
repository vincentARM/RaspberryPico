ARMGNU ?= E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi


AOPS = --warn --fatal-warnings -mcpu=cortex-m0
COPS = -Wall -O2 -ffreestanding -mcpu=cortex-m0
LOPS = -nostdlib -nostartfiles

all : blinkA12.uf2

clean:
	rm -f *.bin
	rm -f *.o
	rm -f *.elf
	rm -f *.list
	rm -f *.uf2

blinkA12.uf2: blinkA12.bin
	python uf2conv.py --family 0xE48BFF56 --base 0x10000000  blinkA12.bin -o blinkA12.uf2
    
blinkA12.o : blinkA12.s
	$(ARMGNU)-as $(AOPS)  blinkA12.s -o blinkA12.o

blinkA12.bin :               memmap.ld blinkA12.o
	$(ARMGNU)-ld  -T memmap.ld  blinkA12.o -o blinkA12.elf  -M >blinkA12_map.txt
	$(ARMGNU)-objdump -D blinkA12.elf > blinkA12.list
	$(ARMGNU)-objcopy -O binary blinkA12.elf blinkA12_dep.bin
	type entete.bin blinkA12_dep.bin > blinkA12.bin

