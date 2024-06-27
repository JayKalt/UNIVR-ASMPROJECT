# -------------------- #
# filename: mainInit.s #
# -------------------- #

.section .data	
	# Integers
	# -----------------------------------------------------------------------
	result:				.int 0			# Numero convertito in decimale
	field_counter:		.int 0			# Numero di campi riempiti
	counter:			.int 0			# Numero dei prodotti contati con il '\n'
	# -----------------------------------------------------------------------

.section .bss
	# Strings
	# -----------------------------------------------------------------------
	buffer:				.string			# Spazio per il buffer di input
	# -----------------------------------------------------------------------

.section .text
	.global mainInit
	.type mainInit, @function
mainInit:

_read_loop:
	# Leggo il file
	movl $3, %eax					# Syscall read
	movl 4(%esp), %ebx				# Sposto il fd in EBX
	movl $buffer, %ecx				# Buffer di input
	movl $1, %edx					# Lunghezza massima
	int $0x80						# Kernel interrupt

	cmpb $0, %al					# Verifico se EOF
	jle _exit_code_ok				# E in caso chiudo il file

	# Sposto il carattere in AL
	movb buffer, %al				# Copio il carattere nel buffer in AL

	# Controllo se ho una nuova linea
	cmpb $10, %al					# Comparo il carattere con '\n' (Decimal ASCII: 10)
	je _new_line					# Se coincide salto alla etichetta indicata

	# Controllo se ho una virgola
	cmpb $44, %al					# Comparo il carattere con ',' (Decimal ASCII: 44)
	je _store						# Se coincide salto alla etichetta indicata

	# Controllo se ho una cifra
	cmpb $48, %al					# Comparo il carattere con '0' (Decimale ASCII: 48)
	jl _exit_code_ko				# Se AL < '1' ho un errore
	cmpb $57, %al					# Comparo il carattere con '9' (Decimale ASCII: 58)
	jg _exit_code_ko				# Se AL > '9' ho un errore

	# Chiamo la funzione atoi
	pushl result					# Salvo il valore del numero nello stack
	call atoi
	popl result						# Riprendo il valore del numero aggiornato

	cmpl $1000, result				# Verifico che le dimensioni non superino le 4 cifre
	jge _exit_code_ko				# In caso, ho un errore

	jmp _read_loop					# Salto al loop iniziale

_new_line:
	incw counter					# Incremento il counter

_store:
	# Salvo il numero ottenuto nella cella di memoria del array e incremento
	movl result, %eax				# Sposto il risultato in EAX
	movl %eax, (%edi)				# Sposto EAX nel indirizzo di memoria di EDI (array)
	addl $4, %edi					# Incremento di una cella di memoria EDI
	addl $1, field_counter

	cmpb $4, field_counter
	jge _exit_code_ko


_reset:
	# Resetto il contenuto di result
	movl $0, result					# Sposto 0 in result
	movl $0, field_counter			# Sposto 0 in field_counter
	jmp _read_loop					# Salto al loop iniziale

_exit_code_ko:
	# Il formato di scrittura del file non rispetta gli standard
	movl $1, %ecx					# Alzo il flag a 1
	ret								# Torno al main

_exit_code_ok:
	# Il formato di scrittura del file riseptta gli standard quindi posso procedere
	# con l analisi dei valori di input
	movl $0, %ecx
	movl counter, %eax
	ret
