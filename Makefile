EXE = pianificatore
AS = as --32 -gstabs
LD = ld -m elf_i386
DEBUG = -gstabs

OBJ = obj/main.o obj/mainInit.o obj/atoi.o obj/validateInput.o obj/sortInit.o obj/algChoice.o obj/parametersOk.o obj/validateInputOk.o obj/fileOpenOk.o obj/fileReadOk.o obj/fileCloseOk.o

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
obj/algChoice.o: src/algChoice.s
	$(AS) -o obj/algChoice.o src/algChoice.s

obj/parametersOk.o: src/parametersOk.s
	$(AS) -o obj/parametersOk.o src/parametersOk.s
obj/validateInputOk.o: src/validateInputOk.s
	$(AS) -o obj/validateInputOk.o src/validateInputOk.s

obj/fileOpenOk.o: src/fileOpenOk.s
	$(AS) -o obj/fileOpenOk.o src/fileOpenOk.s
obj/fileReadOk.o: src/fileReadOk.s
	$(AS) -o obj/fileReadOk.o src/fileReadOk.s
obj/fileCloseOk.o: src/fileCloseOk.s
	$(AS) -o obj/fileCloseOk.o src/fileCloseOk.s


clean:
	rm -f obj/*.o bin/$(EXE) core
