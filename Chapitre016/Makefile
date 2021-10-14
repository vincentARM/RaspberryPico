ARMGNU ?= E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi


AOPS = --warn --fatal-warnings -mcpu=cortex-m0
COPS = -Wall -O2 -ffreestanding -mcpu=cortex-m0
LOPS = -nostdlib -nostartfiles

all : mesureC.uf2

clean:
	rm -f *.bin
	rm -f *.o
	rm -f *.elf
	rm -f *.list
	rm -f *.uf2

mesureC.uf2: mesureC.bin
	python uf2conv.py --family 0xE48BFF56 --base 0x10000000  mesureC.bin -o mesureC.uf2
    
mesureC.o : mesureC.s
	$(ARMGNU)-as $(AOPS)  mesureC.s -o mesureC.o
mesureC.bin :               memmap.ld mesureC.o routinesUSBCDC.o routinesPicoARM.o
	$(ARMGNU)-ld  -T memmap.ld  mesureC.o routinesUSBCDC.o routinesPicoARM.o -o mesureC.elf -M >mesureC_map.txt
	$(ARMGNU)-objdump -D mesureC.elf > mesureC.list
	$(ARMGNU)-objcopy -O binary mesureC.elf mesureC_dep.bin
	type entete.bin mesureC_dep.bin > mesureC.bin
routinesUSBCDC.o : routinesUSBCDC.s
	$(ARMGNU)-as $(AOPS)  routinesUSBCDC.s -o routinesUSBCDC.o
routinesPicoARM.o : routinesPicoARM.s
	$(ARMGNU)-as $(AOPS)  routinesPicoARM.s -o routinesPicoARM.o