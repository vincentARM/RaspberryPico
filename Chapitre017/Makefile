ARMGNU ?= E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi


AOPS = --warn --fatal-warnings -mcpu=cortex-m0
COPS = -Wall -O2 -ffreestanding -mcpu=cortex-m0
LOPS = -nostdlib -nostartfiles

all : testCore1A.uf2

clean:
	rm -f *.bin
	rm -f *.o
	rm -f *.elf
	rm -f *.list
	rm -f *.uf2

testCore1A.uf2: testCore1A.bin
	python uf2conv.py --family 0xE48BFF56 --base 0x10000000  testCore1A.bin -o testCore1A.uf2
    
testCore1A.o : testCore1A.s
	$(ARMGNU)-as $(AOPS)  testCore1A.s -o testCore1A.o
testCore1A.bin :               memmap.ld testCore1A.o routinesUSBCDC.o routinesPicoARM.o routinesMulticore.o
	$(ARMGNU)-ld  -T memmap.ld  testCore1A.o routinesUSBCDC.o routinesPicoARM.o routinesMulticore.o -o testCore1A.elf -M >testCore1A_map.txt
	$(ARMGNU)-objdump -D testCore1A.elf > testCore1A.list
	$(ARMGNU)-objcopy -O binary testCore1A.elf testCore1A_dep.bin
	type entete.bin testCore1A_dep.bin > testCore1A.bin
routinesUSBCDC.o : routinesUSBCDC.s
	$(ARMGNU)-as $(AOPS)  routinesUSBCDC.s -o routinesUSBCDC.o
routinesPicoARM.o : routinesPicoARM.s
	$(ARMGNU)-as $(AOPS)  routinesPicoARM.s -o routinesPicoARM.o
routinesMulticore.o : routinesMulticore.s
	$(ARMGNU)-as $(AOPS)  routinesMulticore.s -o routinesMulticore.o