# ---------------- #
# filename: init.s #
# ---------------- #

.section .data	
	# Variabili per i numeri
	result:				.int 0			# Numero convertito in decimale
	counter:			.int 0			# Numero dei prodotti contati con il '\n'

.section .bss
	buffer:				.string			# Spazio per il buffer input

.section .text
	.global init
	.type init, @function
init:

_read_loop:
	# Leggo il file
	movl $3, %eax					# Syscall read
	movl (%esp), %ebx				# Sposto il fd in EBX
	movl $buffer, %ecx				# Buffer di input
	movl $1, %edx					# Lunghezza massima
	int $0x80						# Kernel interrupt

	cmp $0, %eax					# Verifico no errori / EOF
	jle _return						# E in caso chiudo il file

	# Sposto il carattere in AL
	movb buffer, %al				# Copio il carattere nel buffer in AL

	# Controllo se ho una nuova linea
	cmpb $10, %al					# Comparo il carattere con '\n' (Decimal ASCII: 10)
	je _new_line					# Se coincide salto alla etichetta indicata

	# Controllo se ho una virgola
	cmpb $44, %al					# Comparo il carattere con ',' (Decimal ASCII: 44)
	je _store						# Se coincide salto alla etichetta indicata

	# Chiamo la funzione atoi
	pushl result					# Salvo il valore del numero nello stack
	call atoi						# Chiamo la funzoine
	popl result						# Riprendo il valore del numero aggiornato

	jmp _read_loop					# Salto al loop iniziale

_new_line:
	incw counter					# Incremento il counter

_store:
	# Salvo il numero ottenuto nella cella di memoria del array e incremento
	movl result, %eax				# Sposto il risultato in EAX
	movl %eax, (%esi)				# Sposto EAX nel indirizzo di memoria di ESI (array)
	addl $4, %esi					# Incremento di una cella di memoria ESI

_reset:
	# Resetto il contenuto di result
	movl $0, result					# Sposto 0 in result
	jmp _read_loop					# Salto al loop iniziale

_return:
	movl counter, %eax				# Sposto il valore del contatore in EAX
	ret								# Return
