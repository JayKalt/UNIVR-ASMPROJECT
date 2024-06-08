EXE = pianificatore
AS = as --32 -gstabs
LD = ld -m elf_i386
DEBUG = -gstabs

OBJ = obj/main.o obj/main_init.o obj/atoi.o obj/validateInput.o obj/id_init.o

$(EXE): $(OBJ)
	$(LD) -o bin/$(EXE) $(OBJ)

obj/main.o: src/main.s
	$(AS) -o obj/main.o src/main.s
obj/main_init.o: src/main_init.s
	$(AS) -o obj/main_init.o src/main_init.s
obj/atoi.o: src/atoi.s
	$(AS) -o obj/atoi.o src/atoi.s
obj/validateInput.o: src/validateInput.s
	$(AS) -o obj/validateInput.o src/validateInput.s
obj/id_init.o: src/id_init.s
	$(AS) -o obj/id_init.o src/id_init.s

clean:
	rm -f obj/*.o bin/$(EXE) core
