EXE = final
AS = as --32 -gstabs
LD = ld -m elf_i386
# DEBUG = -gstabs

OBJ = main.o array_init.o atoi.o

$(EXE): $(OBJ)
	$(LD) -o $(EXE) $(OBJ)

main.o: main.s
	$(AS) -o main.o main.s
read_loop: read_loop.s
	$(AS) -o array_init.o array_init.s
atoi: atoi.s
	$(AS) -o atoi.o atoi.s

clean:
	rm -f *.o $(EXE) core
