# ---------------- #
# filename: main.s #
# ---------------- #

.section .data

	# Interi
	numero_prodotti:			.int 0			# Numero del prodotto
	array_sort:					.zero 4 * 10	# Array per il sort (massimo 10 prodotti)
	array_prodotti:				.zero 4 * 40	# Array per i prodotti (massimo 10 prodotti * 4 campi)


	# Stringhe
	# Messaggi di errore
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
	call parametersOk				# Altrimenti stampo un messaggio di OK

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

	call fileOpenOk					# Altrimenti stampo un messaggio di OK


# ------------------------------------------------------------- #
# 		SECONDA PARTE: LETTURA FILE E INIZZALIZZAZIONE ARRAY	#
# ------------------------------------------------------------- #

_file_read:
	# Preparo i registri per la call alla funzione 
	leal array_prodotti, %esi		# Leggo indirizzo di array e sposto in ESI

	call mainInit

	movl %eax, numero_prodotti		# Prendo il contatore salvato in EAX e lo sposto nella variabile

	call fileReadOk

_close_file: 
	# Chiudo il file (non mi serve piu accedere al file ormai)
	movl $6, %eax					# Syscall close
	popl %ebx						# File descriptor da chiudere
	int $0x80						# Kernel interrupt

	call fileCloseOk


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
	call validateInputOk


# ------------------------------------------------------------- #
# 					QUARTA PARTE: MENU PRINCIPALE				#
# ------------------------------------------------------------- #

_menu_principale:
	# Menu principale

	call algChoice

	# Verifico algoritmo inserito
	cmp $1, %eax
	je _exit
	cmp $2, %eax
	jmp _exit



#
#
#
#
#
#
#
#
#
#		DA QUI IN POI SIAMO WORK IN PROGRESS
#
#
#
#
#
#
#
#
#



# ------------------------------------------------------------- #
# 						ALGORITMO HPF							#
# ------------------------------------------------------------- #

_hpf_select:
	# Preparo off-set
	movl $12, %ebx
	jmp _array_sort_init

	# Preparo i registri per la call
	movl numero_prodotti, %eax
	leal array_prodotti, %esi
	jmp _exit

# ------------------------------------------------------------- #
# 						ALGORITMO HPF							#
# ------------------------------------------------------------- #

_edf_select:
	# Preparo off-set
	movl $8, %ebx
	jmp _array_sort_init

	# Preparo i registri per la call
	movl numero_prodotti, %eax
	leal array_prodotti, %esi

# ------------------------------------------------------------- #
# 				INIZIALIZZAZIONE DEL ARRAY SORT					#
# ------------------------------------------------------------- #

_array_sort_init:
	# Inizializzo array contenente solo gli id
	subl $4, %esp					# Creo lo spazio per il valore della return
	movl $1, (%esp)					# Imposto flag 1 sullo stack

	movl numero_prodotti, %eax		# Salvo il numero dei prodotti in EAX
	leal array_prodotti, %esi		# Salvo indirizzo array in ESI
	addl %ebx, %esi					# Mi sposto all'inidirizzo della priorita
	leal array_sort, %edi			# Salvo indirizzo array id in EDI

#	call sort_init

	popl %eax						# Ripristino lo stack recuperando la return in EAX
	cmp $0, %eax					# Verifico che il flag sia stato abbassato
	jg _errore_inserimento_id		# Se flag > 0 ho un errore
	jmp _exit



#
#
#
#
#
#
#
#
#
#		DA QUI IN POI SIAMO NON SIAMO WORK IN PROGRESS
#
#
#
#
#
#
#
#
#



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
