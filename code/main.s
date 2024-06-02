# ---------------- #
# filename: main.s #
# ---------------- #

.section .data

	# Interi
	n_prod:					.int 0			# Numero del prodotto
	prod_array:				.zero 40 * 4	# Array per i prodotti (massimo 10 prodotti)

	# Stringhe
	errore_parametri:		.ascii "Parameters error\t\t> $ ./final <inputfile.txt>\n"
	errore_parametri_len:	.long . - errore_parametri

	errore_apertura:		.ascii "File open error\n"
	errore_apertura_len:	.long . - errore_apertura

.section .text
	.global _start
_start:

_opne:
	# Controllo i parametri
	popl %ebx						# Salvo il numero dei parametri in ebx
	cmp $2, %ebx					# Verifico se è stato passato almeno un argomento
	jl _exit_error					# Se non ci sono argomenti, esco

	# Salvo il nome del file
	popl %ebx						# Puntatore al primo argomento (nome del programma)
	popl %ebx						# Puntatore al secondo argomento (nome del file)

	# Apro il file
	movl $5, %eax					# Syscall file open
	xorl %ecx, %ecx					# Modalita' di apertura del file (O_RDONLY)
	int $0x80						# Kernel interrupt

	# Se si verifica un errore esci dal programma
	cmp $0, %eax					# Controllo il file descriptor
	jl _exit						# Salto alla fine del programma se c'e' un errore

	# Altrimenti continua nel codice

_read_loop:
	# Chiama la read_loop per leggere il file
	call read_loop
	movl %eax, n_prod				# Salvo il contenuto di eax in n_prod

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
	leal errore_parametri, %ecx		# Carico l'indirizzo della variabile
	movl errore_parametri_len, %edx	# Lunghezza della stringa
	int $0x80						# Kernel interrupt
	jmp _exit

_opening_error:
	# Stampo un messaggio di errore apertura file ed esco
	movl $4, %eax					# Syscall write
	movl $1, %ebx					# File descriptor stdout (terminale)
	leal errore_apertura, %ecx		# Carico l'indirizzo della variabile
	movl errore_apertura_len, %edx	# Lunghezza della stringa
	int $0x80						# Kernel interrupt

_exit:
	# Esco dal programma
	movl $1, %eax					# Syscall exit
	xorl %ebx, %ebx					# Codice di usita 0
	int $0x80						# Kernel interrupt
