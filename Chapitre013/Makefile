ARMGNU ?= E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi


AOPS = --warn --fatal-warnings -mcpu=cortex-m0
COPS = -Wall -O2 -ffreestanding -mcpu=cortex-m0
LOPS = -nostdlib -nostartfiles

all : testPico16K.uf2

clean:
	rm -f *.bin
	rm -f *.o
	rm -f *.elf
	rm -f *.list
	rm -f *.uf2

testPico16K.uf2: testPico16K.bin
	python uf2conv.py --family 0xE48BFF56 --base 0x10000000  testPico16K.bin -o testPico16K.uf2
    
testPico16K.o : testPico16K.s
	$(ARMGNU)-as $(AOPS)  testPico16K.s -o testPico16K.o
testPico16K.bin :               memmap.ld testPico16K.o routinesUSB.o routinesPicoARM.o
	$(ARMGNU)-ld  -T memmap.ld  testPico16K.o routinesUSB.o routinesPicoARM.o -o testPico16K.elf -M >testPico16K_map.txt
	$(ARMGNU)-objdump -D testPico16K.elf > testPico16K.list
	$(ARMGNU)-objcopy -O binary testPico16K.elf testPico16K_dep.bin
	type entete.bin testPico16K_dep.bin > testPico16K.bin
routinesUSB.o : routinesUSB.s
	$(ARMGNU)-as $(AOPS)  routinesUSB.s -o routinesUSB.o
routinesPicoARM.o : routinesPicoARM.s
	$(ARMGNU)-as $(AOPS)  routinesPicoARM.s -o routinesPicoARM.o