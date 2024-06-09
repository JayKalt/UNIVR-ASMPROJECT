# ---------------- #
# filename: main.s #
# ---------------- #

.section .data
	# Interi
	algoritmo:					.int 0			# Numero del algoritmo di ordinamento scelto
	numero_prodotti:			.int 0			# Numero del prodotto
	array_sort:					.zero 4 * 10	# Array per il sort (massimo 10 prodotti)
	array_prodotti:				.zero 4 * 40	# Array per i prodotti (massimo 10 prodotti * 4 campi)

	# Stringhe
	errore_parametri:			.ascii "\n\n[x] ERRORE: Inserimento parametri:  > $ ./final <inputfile.txt>\n"
	errore_parametri_len:		.long . - errore_parametri

	errore_apertura:			.ascii "\n\n[x] ERRORE: Apertura file fallita\n"
	errore_apertura_len:		.long . - errore_apertura

	errore_valori:				.ascii "\n\n[x] ERRORE: Valori letti non conformi agli standard\n"
	errore_valori_len:			.long . - errore_valori

	errore_inserimento_id:		.ascii "\n\n[x] ERRORE: Inizializzazione array di ordinamento fallita\n"
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
	pushl %eax						# Salvo il falore del file descriptor sullo stack



# ------------------------------------------------------------- #
# 		SECONDA PARTE: LETTURA FILE E INIZZALIZZAZIONE ARRAY	#
# ------------------------------------------------------------- #

_file_read:
	# Preparo i registri per la call alla funzione 
	leal array_prodotti, %esi		# Leggo indirizzo di array e sposto in ESI

	call mainInit

	movl %eax, numero_prodotti		# Prendo il contatore salvato in EAX e lo sposto nella variabile

_close_file: 
	# Chiudo il file (non mi serve piu accedere al file ormai)
	movl $6, %eax					# Syscall close
	popl %ebx						# File descriptor da chiudere
	int $0x80						# Kernel interrupt



# ------------------------------------------------------------- #
# 			TERZA PARTE: CONTROLLO DEI VALORI INSERITI			#
# ------------------------------------------------------------- #

_values_check:
	# Controllo che i valori letti siano conformi agli standard indicati
	subl $4, %esp					# Creo lo spazio per il valore della return
	movl $1, (%esp)					# Imposto flag 1 sullo stack

	movl numero_prodotti, %eax		# Salvo il numero dei prodotti in EAX
	leal array_prodotti, %esi		# Salvo indirizzo array in ESI

	call validateInput

	popl %eax						# Ripristino lo stack recuperando la return in EAX
	cmp $0, %eax					# Verifico che il flag sia stato abbassato
	jg _errore_valori				# Se flag > 0 ho un errore



# ------------------------------------------------------------- #
# 					QUARTA PARTE: MENU PRINCIPALE				#
# ------------------------------------------------------------- #

_menu_principale:
	# Menu principale

	call algChoice

	movl %eax, algoritmo



# ------------------------------------------------------------- #
# 		QUINTA PARTE: INIZIALIZZAZIONE DEL SORT ARRAY			#
# ------------------------------------------------------------- #

_off_set_init:
	# Inizializzo off-set a seconda del algoritmo scelto
	cmpb $1, algoritmo
	jne _edf_select

_hpf_select:
	# Imposto off-set di HPF
	movl $12, %ebx
	jmp _sort_init

_edf_select:
	# Imposto off-set di EDF
	movl $8, %ebx

_sort_init:
	# Inizializzo array per il sort
	subl $4, %esp					# Creo lo spazio per il valore della return
	movl $1, (%esp)					# Imposto flag 1 sullo stack

	movl numero_prodotti, %eax		# Salvo il numero dei prodotti in EAX
	leal array_prodotti, %esi		# Salvo indirizzo array in ESI
	addl %ebx, %esi					# Mi sposto al inidirizzo della priorita
	leal array_sort, %edi			# Salvo indirizzo array id in EDI

	call sortInit

	popl %eax						# Ripristino lo stack recuperando la return in EAX
	cmp $0, %eax					# Verifico che il flag sia stato abbassato
	jg _errore_inserimento_id		# Se flag > 0 ho un errore



# ------------------------------------------------------------- #
# 					 SESTA PARTE: ALGORITMO						#
# ------------------------------------------------------------- #

	# Salvo i valori nello stack per la call 
	leal array_sort, %esi
	pushl numero_prodotti

	# Scelgo algoritmo
	cmpb $1, algoritmo
	jne _edf

_hpf:
	# Chiamo algoritmo HPF
	call hpf
	jmp _test

_edf:
	# Chiamo algoritmo EDF
	call hpf
	jmp _exit



# ------------------------------------------------------------- #
# 					 TESTING IN PROGRESS						#
# ------------------------------------------------------------- #

_test:
	# Inizializzo array per il sort
	subl $4, %esp					# Creo lo spazio per il valore della return
	movl $1, (%esp)					# Imposto flag 1 sullo stack

	movl numero_prodotti, %eax		# Salvo il numero dei prodotti in EAX
	leal array_sort, %esi			# Salvo indirizzo array id in EDI

	call sortRev

	popl %eax						# Ripristino lo stack recuperando la return in EAX
	cmp $0, %eax					# Verifico che il flag sia stato abbassato
	jg _errore_inserimento_id		# Se flag > 0 ho un errore

	jmp _exit



# ------------------------------------------------------------- #
# 				LABELS PER I MESSAGGI DI ERRORE					#
# ------------------------------------------------------------- #

_errore_parametri:
	leal errore_parametri, %ecx				# Destinazione
	movl errore_parametri_len, %edx			# Lunghezza
	jmp _stampa_errore

_errore_apertura:
	leal errore_apertura, %ecx
	movl errore_apertura_len, %edx
	jmp _stampa_errore

_errore_valori:
	leal errore_valori, %ecx
	movl errore_valori_len, %edx
	jmp _stampa_errore

_errore_inserimento_id:
	leal errore_inserimento_id, %ecx
	movl errore_inserimento_id_len, %edx
	jmp _stampa_errore

_stampa_errore:
	# Stampo un messaggio a video
	movl $4, %eax					# Syscall write
	movl $1, %ebx					# File descriptor stdout (terminale)
	int $0x80						# Kernel interrupt

_exit:
	# Esco dal programma
	movl $1, %eax					# Syscall exit
	xorl %ebx, %ebx					# Codice di usita 0
	int $0x80						# Kernel interrupt
