# ---------------- #
# filename: main.s #
# ---------------- #

.section .data

	# Interi
	fd:							.int 0			# File Descriptor del documento
	numero_prodotti:			.int 0			# Numero del prodotto
	array_id_prodotti:			.zero 4 * 10	# Array indici prodotto (massimo 10 prodotti)
	array_prodotti:				.zero 4 * 40	# Array per i prodotti (massimo 10 prodotti * 4 campi)


	# Stringhe
	# Messaggi di errore
	errore_parametri:			.ascii "Errore inserimento parametri:\n\t> $ ./final <inputfile.txt>\n\n"
	errore_parametri_len:		.long . - errore_parametri

	errore_apertura:			.ascii "Errore apertura file\n"
	errore_apertura_len:		.long . - errore_apertura

	errore_valori:				.ascii "Errore valori letti\n"
	errore_valori_len:			.long . - errore_valori

	errore_inserimento_id:		.ascii "Errore inserimento id\n"
	errore_inserimento_id_len:	.long . - errore_inserimento_id

.section .text
	.global _start
_start:

# ------------------------------------------------------------- #
# 		PRIMA PARTE: RECUPERO PARAMETRI E APERTURA FILE			#
# ------------------------------------------------------------- #

_parameters_check:
	# Controllo i parametri
	popl %ebx						# Salvo il numero dei parametri in EBX
	cmpl $2, %ebx					# Verifico se è stato passato almeno un argomento
	jne _errore_parametri			# Se non ci sono argomenti o sono piu di 2, esco

	# Salvo il nome del file
	popl %ebx						# Puntatore al primo argomento (nome del programma)
	popl %ebx						# Puntatore al secondo argomento (nome del file)

_file_open:
	# A questo punto ho gia in EBX il puntatore al nome del file quindi mi basta
	# inserire 5 in EAX e azzerare ECX per indicare la modalita di lettura
	movl $5, %eax					# Syscall file open
	xorl %ecx, %ecx					# Modalita di apertura del file (O_RDONLY)
	int $0x80						# Kernel interrupt

	# Verifico la return della syscall
	cmp $0, %eax					# Controllo il valore della return
	jl _errore_apertura				# Salto alla fine del programma se ho un errore
	movl %eax, fd					# Altrimenti salvamelo nella variabile



# ------------------------------------------------------------- #
# 	SECONDA PARTE: LETTURA FILE E INIZZALIZZAZIONE ARRAY		#
# ------------------------------------------------------------- #

_file_read:
	# Preparo i registri per la call alla funzione 
	leal array_prodotti, %esi		# Leggo indirizzo di array e sposto in ESI
	pushl %eax						# salvo sullo stack il fd

	call main_init

	addl $4, %esp					# Ripristino ESP
	movl %eax, numero_prodotti		# Prendo il contatore salvato in EAX e lo sposto nella variabile

_close_file: 
	# Chiudo il file (non mi serve piu accedere al file ormai)
	movl $6, %eax					# Syscall close
	movl fd, %ecx					# File descriptor da chiudere
	int $0x80						# Kernel interrupt



# ------------------------------------------------------------- #
# 		TERZA PARTE: CONTROLLO DEI VALORI INSERITI				#
# ------------------------------------------------------------- #

_values_check:
	# Controllo che i valori letti siano conformi agli standard indicati
	subl $4, %esp					# Creo lo spazio per il valore della return
	movl $1, (%esp)					# Imposto flag 1 sullo stack

	movl numero_prodotti, %eax		# Salvo il numero dei prodotti in EAX
	leal array_prodotti, %esi		# Salvo indirizzo array in ESI

	call validateInput

	popl %eax						# Salvo il valore di return in EAX
	cmp $0, %eax					# Verifico che il flag sia stato abbassato
	jg _errore_valori				# Se flag > 0 ho un errore
	jmp _exit						# Altrimenti, tutto ok



# ------------------------------------------------------------- #
# 				INIZIALIZZAZIONE ARRAY DEGLI ID					#
# ------------------------------------------------------------- #

_id_array_init:
	# Inizializzo array contenente solo gli id
	subl $4, %esp
	movl $1, (%esp)

	movl numero_prodotti, %eax
	leal array_prodotti, %esi
	leal array_id_prodotti, %edi

	call id_init

	popl %eax
	cmp $0, %eax
	jg _errore_inserimento_id
	jmp _exit


# ------------------------------------------------------------- #
# 				CHIAMATE PER I MESSAGGI DI ERRORE				#
# ------------------------------------------------------------- #

_errore_parametri:
	# Stampo un messaggio di errore parametri ed esco
	movl $4, %eax					# Syscall write
	movl $1, %ebx					# File descriptor stdout (terminale)
	leal errore_parametri, %ecx		# Carico indirizzo della variabile
	movl errore_parametri_len, %edx	# Lunghezza della stringa
	int $0x80						# Kernel interrupt
	jmp _exit

_errore_apertura:
	# Stampo un messaggio di errore apertura file ed esco
	movl $4, %eax
	movl $1, %ebx
	leal errore_apertura, %ecx
	movl errore_apertura_len, %edx
	int $0x80
	jmp _exit

_errore_valori:
	# Stampo un messaggio di errore valori inseriti ed esco
	movl $4, %eax
	movl $1, %ebx
	leal errore_valori, %ecx
	movl errore_valori_len, %edx
	int $0x80
	jmp _exit

_errore_inserimento_id:
	# Stampo un messaggio di errore valori inseriti ed esco
	movl $4, %eax
	movl $1, %ebx
	leal errore_inserimento_id, %ecx
	movl errore_inserimento_id_len, %edx
	int $0x80
	jmp _exit


_exit:
	# Esco dal programma
	movl $1, %eax					# Syscall exit
	xorl %ebx, %ebx					# Codice di usita 0
	int $0x80						# Kernel interrupt
