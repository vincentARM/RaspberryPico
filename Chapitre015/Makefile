ARMGNU ?= E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi


AOPS = --warn --fatal-warnings -mcpu=cortex-m0
COPS = -Wall -O2 -ffreestanding -mcpu=cortex-m0
LOPS = -nostdlib -nostartfiles

all : affFloatA.uf2

clean:
	rm -f *.bin
	rm -f *.o
	rm -f *.elf
	rm -f *.list
	rm -f *.uf2

affFloatA.uf2: affFloatA.bin
	python uf2conv.py --family 0xE48BFF56 --base 0x10000000  affFloatA.bin -o affFloatA.uf2
    
affFloatA.o : affFloatA.s
	$(ARMGNU)-as $(AOPS)  affFloatA.s -o affFloatA.o
affFloatA.bin :               memmap.ld affFloatA.o routinesUSBCDC.o routinesPicoARM.o
	$(ARMGNU)-ld  -T memmap.ld  affFloatA.o routinesUSBCDC.o routinesPicoARM.o -o affFloatA.elf -M >affFloatA_map.txt
	$(ARMGNU)-objdump -D affFloatA.elf > affFloatA.list
	$(ARMGNU)-objcopy -O binary affFloatA.elf affFloatA_dep.bin
	type entete.bin affFloatA_dep.bin > affFloatA.bin
routinesUSBCDC.o : routinesUSBCDC.s
	$(ARMGNU)-as $(AOPS)  routinesUSBCDC.s -o routinesUSBCDC.o
routinesPicoARM.o : routinesPicoARM.s
	$(ARMGNU)-as $(AOPS)  routinesPicoARM.s -o routinesPicoARM.o