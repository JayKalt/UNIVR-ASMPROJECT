# ---------------- #
# filename: main.s #
# ---------------- #

.section .data
	# Integers
	# -----------------------------------------------------------------------
	numero_parametri:			.int 0		# Numero dei parametri inseriti
	numero_prodotti:			.int 0		# Numero dei prodotti nel file
	algoritmo:					.int 0		# Numero del algoritmo di ordinamento scelto
	# -----------------------------------------------------------------------
	penalty:					.int 0		# Penalty in euro
	# -----------------------------------------------------------------------


	# Array
	# -----------------------------------------------------------------------
	array_sort:					.zero 4 * 10	# Array per il sort (massimo 10 prodotti)
	array_prodotti:				.zero 4 * 40	# Array per i prodotti (massimo 10 prodotti * 4 campi)
	# -----------------------------------------------------------------------


	# ASCII
	# -----------------------------------------------------------------------
	parameters_err:				.ascii "\n\n[x] ERRORE: Parametri non correti:\n\tSolo input > $ ./pianificatore <inputfile.txt>\n\tInput + output > $ ./pianificatore </path/to/inputfile.txt> </path/to/outputfile.txt>\n"
	parameters_err_len:			.long . - parameters_err
	
	file_opening_err:			.ascii "\n\n[x] ERRORE: Apertura file fallita\n"
	file_opening_err_len:		.long . - file_opening_err

	input_validate_err:			.ascii "\n\n[x] ERRORE: Parametri inseriti non conformi agli standard\n"
	input_validate_err_len:		.long . - input_validate_err

	empty_file_err:				.ascii "\n\n[x] ERRORE: File di input vuoto\n"
	empty_file_err_len:			.long . - empty_file_err

	# -----------------------------------------------------------------------

.section .text
	.global _start
_start:

# ------------------------------------------------------------- #
# 		PRIMA PARTE: RECUPERO PARAMETRI E APERTURA FILE			#
# ------------------------------------------------------------- #

_parameters_validation:
	# Controllo i parametri
	popl numero_parametri			# Salvo il numero dei parametri
	cmpl $3, numero_parametri		# Verifico se ho piu  di 3 parametri 
	jg _parameters_err				# Se ho un errore, esco
	cmpl $2, numero_parametri		# Verifico se ho meno di 2 parametri
	jl _parameters_err				# Se ho un errore, esco

	# Inizio a salvare i vari nomi dei file
	popl %ebx						# Puntatore al primo argomento (nome del programma)
	popl %ebx						# Puntatore al secondo argomento (nome del file di input)

_file_open:
	# A questo punto ho gia in EBX il puntatore al nome del file quindi mi basta
	# inserire 5 in EAX come codice di open e azzerare ECX per indicare la modalita di lettura
	movl $5, %eax					# Syscall file open
	xorl %ecx, %ecx					# Modalita di apertura del file (O_RDONLY)
	int $0x80						# Kernel interrupt

	# Verifico la return della syscall
	cmp $0, %eax					# Controllo il valore della return
									# Se il risultato della syscall >= 0 non ho errori
									# Mi viene restituito in EAX il file descriptor
	jl _file_opening_err			# Salto alla fine del programma se ho un errore



# ------------------------------------------------------------- #
# 		SECONDA PARTE: LETTURA FILE E INIZZALIZZAZIONE ARRAY	#
# ------------------------------------------------------------- #

_file_read:
	# Preparo i registri per la call alla funzione 
	leal array_prodotti, %edi		# Leggo indirizzo di array principale e sposto in EDI
	pushl %eax						# Salvo il file descriptor sullo stack

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

_validate_input:
	# Verifico di avere un numero di prodotti conforme agli standard indicat (1 - 10)
	cmpb $0, numero_prodotti
	je _empty_file_err
	jl _input_validate_err

	# Controllo che i valori letti siano conformi agli standard indicati	
	movl numero_prodotti, %eax		# Salvo il numero dei prodotti in EAX
	leal array_prodotti, %esi		# Salvo indirizzo array in ESI questa volta

	pushl $1						# Imposto il flag a 1
	
	call validateInput

	popl %eax						# Ripristino lo stack
	cmpb $0, %al					# Verifico il valore della return
	jg _input_validate_err			# Se flag ancora a 1, ho un errore



# ------------------------------------------------------------- #
# 					QUARTA PARTE: MENU PRINCIPALE				#
# ------------------------------------------------------------- #

_main_menu:
	# Menu principale
	call menChoice
	
	cmpl $0, %eax
	jz _exit

	movl %eax, algoritmo



# ------------------------------------------------------------- #
# 			QUINTA PARTE: INIZIALIZZAZIONE ARRAY DI SORT		#
# ------------------------------------------------------------- #

_sort_init_set_up:
	# Imposto i registri per la call
	movl numero_prodotti, %eax		# Salvo il numero dei prodotti in EAX
	leal array_prodotti, %esi		# Salvo indirizzo array in ESI
	leal array_sort, %edi			# Salvo indirizzo array sort in EDI

_offset_set_up:
	# Inizializzo offset per il campo a seconda del algoritmo scelto
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
	# Verifico di poter eseguire un algoritmo (ci devono essere almeno 2 prodotti)
	cmpb $2, numero_prodotti
	jl _sort_update_setup

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



# ------------------------------------------------------------- #
# 				SETTIMA PARTE: SORT ARRAY UPDATE				#
# ------------------------------------------------------------- #

_sort_update_setup:
	# Ripristino degli indirizzi al ID corrispondente
	movl numero_prodotti, %ecx		# Salvo il numero dei prodotti in EAX
	leal array_sort, %esi			# Salvo indirizzo array sort in ESI

	# Verifico algoritmo
	cmpb $1, algoritmo
	jne _select8

_select12:
	movl $12, %edx
	jmp _sortUpdate

_select8:
	movl $8, %edx

_sortUpdate:
	call sortUpdate



# ------------------------------------------------------------- #
# 				OTTAVA PARTE: CALCOLO PENALTY					#
# ------------------------------------------------------------- #

_penalty:
	# Verifico di poter eseguire un algoritmo (ci devono essere almeno 2 prodotti)
	cmpb $2, numero_prodotti
	jl _send_2_terminal

	# Calcolo la penalty generata dal algoritmo selezionato
	leal array_sort, %esi				# Carico array del sort in ESI
	movl numero_prodotti, %ecx			# Carico il numero dei prodotti in ECX
	pushl penalty						# Carico sullo stack la variabile per la penalty
	pushl $0							# Carico sullo stack il tempo finale (0 al inizio)

	call penaltyCalc

	addl $4, %esp
	popl penalty						# Aggiorno il valore delle variabili



# ------------------------------------------------------------- #
# 						NONA PARTE: OUTPUT						#
# ------------------------------------------------------------- #

_send_2_terminal:
	leal array_sort, %esi
	pushl algoritmo
	pushl numero_prodotti
	pushl penalty
	pushl $1

	call send2fd

	addl $16, %esp

_send_2_output_file:
	cmpl $3, numero_parametri
	jne	_stat_reset

	# Apro il file di output in scrittura
	movl $5, %eax						# Syscall OPEN
	popl %ebx							# Prendo il filename dallo stack
	movl $1, %ecx						# Modalita WRITE (O_WRITE)
	int $0x80							# Kernel interrupt

	pushl %ebx							# Carico di nuovo sullo stack il valore
										# del file di output per una futura lettura

	cmpb $0, %al						# Verifico di aver aperto correttamente il file
	jl _file_opening_err				# Altrimenti ho un errore


	# Truncate file (pulisco il contenuto del file)
	movl %eax, %ebx						# Valore del file descriptor ritornato dalla OPEN
	movl $93, %eax						# Syscall FTRUNCATE
	movl $0, %ecx						# Nuova dimensione del file (0 per pulire il contenuto)
	int $0x80							# Kenerl interrupt

	movl %ebx, %eax						# Riporto il fd in EAX per essere pushato come argomento

	# Carico i parametri sullo stack
	leal array_sort, %esi				# Sposto in ESI il valore del array di sort
	pushl algoritmo						# Carico algoritmo selezionato
	pushl numero_prodotti				# Carico i numeri dei prodotti (il mio counter)
	pushl penalty						# Carico il valore della penalty
	pushl %eax							# Carico il file descriptor

	call send2fd

	# Chiudo e salvo il file
	movl $6, %eax						# Syscall CLOSE			
	popl %ebx							# Prendo il file descriptor dallo stack
	int $0x80							# Kernel interrupt

	addl $12, %esp						# Infine ripristino lo stack considerando che ho gia
										# scaricato il file descriptor

_stat_reset:
	# Azzero i valori per il nuovo ciclo
	movl $0, penalty					# Azzero la penalty
	jmp	_main_menu						#



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

_empty_file_err:
	leal empty_file_err, %ecx
	movl empty_file_err_len, %edx

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
