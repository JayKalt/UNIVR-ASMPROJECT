# ---------------- #
# filename: main.s #
# ---------------- #

.section .data
	# Integers
	algoritmo:					.int 0			# Numero del algoritmo di ordinamento scelto
	numero_prodotti:			.int 0			# Numero del prodotto
	array_sort:					.zero 4 * 10	# Array per il sort (massimo 10 prodotti)
	array_prodotti:				.zero 4 * 40	# Array per i prodotti (massimo 10 prodotti * 4 campi)

	# Strings
	parameters_err:				.ascii "\n\n[x] ERRORE: Inserimento parametri:  > $ ./final <inputfile.txt>\n"
	parameters_err_len:			.long . - parameters_err

	file_opening_err:			.ascii "\n\n[x] ERRORE: Apertura file fallita\n"
	file_opening_err_len:		.long . - file_opening_err

	input_validate_err:			.ascii "\n\n[x] ERRORE: Parametri inseriti non conformi agli standard\n"
	input_validate_err_len:		.long . - input_validate_err

.section .text
	.global _start
_start:

# ------------------------------------------------------------- #
# 		PRIMA PARTE: RECUPERO PARAMETRI E APERTURA FILE			#
# ------------------------------------------------------------- #

_parameters_validation:
	# Controllo i parametri
	popl %ebx						# Salvo il numero dei parametri in EBX
	cmpl $2, %ebx					# Verifico se è stato passato almeno un argomento
	jne _parameters_err				# Se non ci sono argomenti o sono piu di 2, esco

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
	jl _file_opening_err			# Salto alla fine del programma se ho un errore
	pushl %eax						# Salvo il falore del file descriptor sullo stack



# ------------------------------------------------------------- #
# 		SECONDA PARTE: LETTURA FILE E INIZZALIZZAZIONE ARRAY	#
# ------------------------------------------------------------- #

_file_read:
	# Preparo i registri per la call alla funzione 
	leal array_prodotti, %esi		# Leggo indirizzo di array e sposto in ESI

	call mainInit

	movl %eax, numero_prodotti		# Prendo il contatore salvato in EAX e lo sposto nella variabile

_file_close: 
	# Chiudo il file (non mi serve piu accedere al file ormai)
	movl $6, %eax					# Syscall close
	popl %ebx						# File descriptor da chiudere (precedentemente salvato sullo stack)
	int $0x80						# Kernel interrupt



# ------------------------------------------------------------- #
# 			TERZA PARTE: CONTROLLO DEI VALORI INSERITI			#
# ------------------------------------------------------------- #

_values_validation:
	# Controllo che i valori letti siano conformi agli standard indicati
	movl numero_prodotti, %eax		# Salvo il numero dei prodotti in EAX
	leal array_prodotti, %esi		# Salvo indirizzo array in ESI

	pushl $1						# Imposto il flag a 1
	
	call validateInput

	popl %eax						# Ripristino lo stack
	cmp $0, %eax					# Verifico la return
	jg _input_validate_err			# Se flag ancora a 1, ho un errore



# ------------------------------------------------------------- #
# 					QUARTA PARTE: MENU PRINCIPALE				#
# ------------------------------------------------------------- #

_main_menu:
	# Menu principale

	call menChoice

	movl %eax, algoritmo



# ------------------------------------------------------------- #
# 		QUINTA PARTE: INIZIALIZZAZIONE DEL SORT ARRAY			#
# ------------------------------------------------------------- #

_sort_registers_set_up:
	# Imposto i registri per la call
	movl numero_prodotti, %eax		# Salvo il numero dei prodotti in EAX
	leal array_prodotti, %esi		# Salvo indirizzo array in ESI
	leal array_sort, %edi			# Salvo indirizzo array sort in EDI

_field_set_up:
	# Inizializzo campo a seconda del algoritmo scelto
	cmpb $1, algoritmo
	jne _edf_select

_hpf_select:
	# Imposto campo di HPF (priorita -> offset: +12 byte)
	addl $12, %esi					# Mi sposto al inidirizzo della priorita
	jmp _sort_init

_edf_select:
	# Imposto campo di EDF (scadenza -> offset: +8  byte)
	addl $8, %esi					# Mi sposto al inidirizzo della priorita

_sort_init:
	call sortInit



# ------------------------------------------------------------- #
# 					 SESTA PARTE: ALGORITMO						#
# ------------------------------------------------------------- #

_algorithm_set_up:
	# Salvo i valori nello stack per la call 
	leal array_sort, %esi			# Salvo in ESI indirizzo array per il sort
	pushl numero_prodotti			# Salvo il numero prodotti nello stack (limite per il ciclo)

	# Scelgo algoritmo
	cmpb $1, algoritmo
	jne _edf

_hpf:
	# Chiamo algoritmo HPF
	call hpf
	jmp _stack_restore

_edf:
	# Chiamo algoritmo EDF
	call edf

_stack_restore:
	# Ripristino stack
	addl $4, %esp

	jmp _exit


# ------------------------------------------------------------- #
# 						 WORK IN PROGRESS						#
# ------------------------------------------------------------- #

_update_main:
	# Verifico algoritmo
	cmpb $1, algoritmo
	jne _push12

_push16:
	pushl $16

_push12:
	pushl $12

	# Inizializzo registri per il restore
	movl numero_prodotti, %eax		# Salvo il numero dei prodotti in EAX
	leal array_sort, %esi			# Salvo indirizzo array id in EDI

#	call sortRest

	jmp _exit



# ------------------------------------------------------------- #
# 				LABELS PER I MESSAGGI DI ERRORE					#
# ------------------------------------------------------------- #

_parameters_err:
	leal parameters_err, %ecx				# Source
	movl parameters_err_len, %edx			# Lunghezza
	jmp _print_err

_file_opening_err:
	leal file_opening_err, %ecx
	movl file_opening_err_len, %edx
	jmp _print_err

_input_validate_err:
	leal input_validate_err, %ecx
	movl input_validate_err_len, %edx
	jmp _print_err

_print_err:
	# Stampo il messaggio di errore a video
	movl $4, %eax					# Syscall write
	movl $1, %ebx					# File descriptor stdout (terminale)
	int $0x80						# Kernel interrupt

_exit:
	# Esco dal programma
	movl $1, %eax					# Syscall exit
	xorl %ebx, %ebx					# Codice di usita 0
	int $0x80						# Kernel interrupt
