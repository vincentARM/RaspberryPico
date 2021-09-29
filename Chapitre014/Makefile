ARMGNU ?= E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi


AOPS = --warn --fatal-warnings -mcpu=cortex-m0
COPS = -Wall -O2 -ffreestanding -mcpu=cortex-m0
LOPS = -nostdlib -nostartfiles

all : testPico16L.uf2

clean:
	rm -f *.bin
	rm -f *.o
	rm -f *.elf
	rm -f *.list
	rm -f *.uf2

testPico16L.uf2: testPico16L.bin
	python uf2conv.py --family 0xE48BFF56 --base 0x10000000  testPico16L.bin -o testPico16L.uf2
    
testPico16L.o : testPico16L.s
	$(ARMGNU)-as $(AOPS)  testPico16L.s -o testPico16L.o
testPico16L.bin :               memmap.ld testPico16L.o routinesUSBCDC.o routinesPicoARM.o
	$(ARMGNU)-ld  -T memmap.ld  testPico16L.o routinesUSBCDC.o routinesPicoARM.o -o testPico16L.elf -M >testPico16L_map.txt
	$(ARMGNU)-objdump -D testPico16L.elf > testPico16L.list
	$(ARMGNU)-objcopy -O binary testPico16L.elf testPico16L_dep.bin
	type entete.bin testPico16L_dep.bin > testPico16L.bin
routinesUSBCDC.o : routinesUSBCDC.s
	$(ARMGNU)-as $(AOPS)  routinesUSBCDC.s -o routinesUSBCDC.o
routinesPicoARM.o : routinesPicoARM.s
	$(ARMGNU)-as $(AOPS)  routinesPicoARM.s -o routinesPicoARM.o