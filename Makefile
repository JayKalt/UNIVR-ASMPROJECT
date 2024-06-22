EXE = pianificatore
AS = as --32 -gstabs
LD = ld -m elf_i386
DEBUG = -gstabs

OBJ = obj/main.o obj/mainInit.o obj/atoi.o obj/validateInput.o obj/sortInit.o obj/menChoice.o obj/hpf.o obj/edf.o obj/movToId.o

$(EXE): $(OBJ)
	$(LD) -o bin/$(EXE) $(OBJ)

obj/main.o: src/main.s
	$(AS) -o obj/main.o src/main.s
obj/mainInit.o: src/mainInit.s
	$(AS) -o obj/mainInit.o src/mainInit.s
obj/atoi.o: src/atoi.s
	$(AS) -o obj/atoi.o src/atoi.s
obj/validateInput.o: src/validateInput.s
	$(AS) -o obj/validateInput.o src/validateInput.s
obj/sortInit.o: src/sortInit.s
	$(AS) -o obj/sortInit.o src/sortInit.s
obj/menChoice.o: src/menChoice.s
	$(AS) -o obj/menChoice.o src/menChoice.s
obj/hpf.o: src/hpf.s
	$(AS) -o obj/hpf.o src/hpf.s
obj/edf.o: src/edf.s
	$(AS) -o obj/edf.o src/edf.s

# Work in progress
obj/movToId.o: src/movToId.s
	$(AS) -o obj/movToId.o src/movToId.s


clean:
	rm -f obj/*.o bin/$(EXE) core
