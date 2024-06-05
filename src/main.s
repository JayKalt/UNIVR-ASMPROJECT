# ---------------- #
# filename: main.s #
# ---------------- #

.section .data

	# Interi
	numero_prodotti:			.int 0			# Numero del prodotto
	array_id_prodotti:			.zero 4 * 10	# Array indici prodotto (massimo 10 prodotti)
	array_prodotti:				.zero 4 * 40	# Array per i prodotti (massimo 10 prodotti * 4 campi)


	# Stringhe
	# Messaggi di errore
	errore_parametri:		.ascii "Parameters error:\n\t> $ ./final <inputfile.txt>\n\n"
	errore_parametri_len:	.long . - errore_parametri

	errore_apertura:		.ascii "File open error\n"
	errore_apertura_len:	.long . - errore_apertura

.section .text
	.global _start
_start:

_opne_file:
	# Controllo i parametri
	popl %ebx						# Salvo il numero dei parametri in EBX
	cmp $2, %ebx					# Verifico se è stato passato almeno un argomento
	jne _exit_error					# Se non ci sono argomenti o sono piu di 2, esco

	# Salvo il nome del file
	popl %ebx						# Puntatore al primo argomento (nome del programma)
	popl %ebx						# Puntatore al secondo argomento (nome del file)

	# Apro il file
	# A questo punto ho gia in EBX il puntatore al nome del file quindi mi basta
	# inserire 5 in EAX e azzerare ECX per indicare la modalita di lettura
	movl $5, %eax					# Syscall file open
	xorl %ecx, %ecx					# Modalita di apertura del file (O_RDONLY)
	int $0x80						# Kernel interrupt

	# Se tutto va bene, viene caricato in EAX il file descriptor
	cmp $0, %eax					# Controllo il file descriptor restituito dalla syscall
	jl _opening_error				# Salto alla fine del programma se ho un errore

	# Altrimenti continua nel codice

_read_file:
	# Preparo i registri per la call alla funzione 
	leal array_prodotti, %esi		# Salvo l'indice del array in ESI
	call init						# Tutti i registri sono pronti, call della funzione
	movl %eax, numero_prodotti		# Prendo il valore salvato in EAX e lo sposto nella variabile

_close_file: 
	# Chiudo il file
	movl $6, %eax					# Syscall close
	movl %ebx, %ecx					# File descriptor da chiudere
	int $0x80						# Kernel interrupt 
	jmp _exit

_exit_error:
	# Stampo un messaggio di errore parametri ed esco
	movl $4, %eax					# Syscall write
	movl $1, %ebx					# File descriptor stdout (terminale)
	leal errore_parametri, %ecx		# Carico indirizzo della variabile
	movl errore_parametri_len, %edx	# Lunghezza della stringa
	int $0x80						# Kernel interrupt
	jmp _exit

_opening_error:
	# Stampo un messaggio di errore apertura file ed esco
	movl $4, %eax					# Syscall write
	movl $1, %ebx					# File descriptor stdout (terminale)
	leal errore_apertura, %ecx		# Carico indirizzo della variabile
	movl errore_apertura_len, %edx	# Lunghezza della stringa
	int $0x80						# Kernel interrupt

_exit:
	# Esco dal programma
	movl $1, %eax					# Syscall exit
	xorl %ebx, %ebx					# Codice di usita 0
	int $0x80						# Kernel interrupt
