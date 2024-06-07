EXE = pianificatore
AS = as --32 -gstabs
LD = ld -m elf_i386
DEBUG = -gstabs

OBJ = obj/main.o obj/init.o obj/atoi.o obj/validateInput.o

$(EXE): $(OBJ)
	$(LD) -o bin/$(EXE) $(OBJ)

obj/main.o: src/main.s
	$(AS) -o obj/main.o src/main.s
obj/init.o: src/init.s
	$(AS) -o obj/init.o src/init.s
obj/atoi.o: src/atoi.s
	$(AS) -o obj/atoi.o src/atoi.s
obj/validateInput.o: src/validateInput.s
	$(AS) -o obj/validateInput.o src/validateInput.s

clean:
	rm -f obj/*.o bin/$(EXE) core
