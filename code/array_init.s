# ---------------------- #
# filename: array_init.s #
# ---------------------- #

.section .data	
	# Variabili per i numeri
	result:				.int 0			# Numero convertito in decimale
	counter:			.int 0			# Numero dei prodotti contati con il '\n'
	fd:					.int 0

.section .bss
	buffer:				.string			# Spazio per il buffer input

.section .text
	.global array_init
	.type array_init, @function
array_init:

	movl %esp, %ebp
	pushl %ebp

	movl %eax, fd

_read_loop:
	# Leggo il file
	movl $3, %eax					# Syscall read
	movl fd, %ebx					# Sposto il fd in EBX
	movl $buffer, %ecx				# Buffer di input
	movl $1, %edx					# Lunghezza massima
	int $0x80						# Kernel interrupt

	cmp $0, %eax					# Verifico no errori / EOF
	jle _return						# E in caso chiudo il file

	# Sposto il carattere in AL
	movl buffer, %eax				# Copio il carattere nel buffer in AL

	# Controllo se ho una nuova linea
	cmpb $10, %al					# Comparo il carattere con '\n'
	je _new_line					# Se coincide salto alla etichetta indicata

	# Controllo se ho una virgola
	cmpb $44, %al					# Comparo il carattere con ','
	je _store						# Se coincide salto alla etichetta indicata

	# Chiamo la funzione atoi
	pushl result					# Salvo il valore di result nello stack
	call atoi						# Chiamo la funzoine
	popl result						# Salvo il risultato in result

	jmp _read_loop

_new_line:
	incw counter					# Incremento il counter

_store:
	movl result, %eax
	movl %eax, (%esi)
	addl $4, %esi

_reset:
	# Resetto il contenuto di result
	movl $0, result
	jmp _read_loop

_return:
	popl %ebp 
	movl counter, %eax
	ret
