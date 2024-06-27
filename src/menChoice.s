# ------------------- #
# filename: menChoice #
# ------------------- #

.section .data
	# Scritte del menu
	menu_header:				.ascii "\n\n+-----------------------------------------------+\n|       PIANIFICATORE  -  MENU PRINCIPALE       |\n+-----------------------------------------------+\n\n"
	menu_header_len:			.long . - menu_header
	menu_contenuto:				.ascii "Scegli con quale algoritmo ordinare i prodotti:\n\n\t1. HPF: High Priority First\n\t\tI prodotti con priorità più alta sono realizzati prima\n\t2. EDF: Erliest Deadline First\n\t\tI prodotti con scadenza piu' prossima sono realizzati prima\n\t3. EXIT\n\n"
	menu_contenuto_len:			.long . - menu_contenuto

	menu_scelta:				.ascii "Inserisci opzione --> "
	menu_scelta_len:			.long . - menu_scelta

	menu_scelta_errore:			.ascii "\n[x] ERRORE: Il valore inserito non corrisponde a nessun algoritmo\n"
	menu_scelta_errore_len:		.long . - menu_scelta_errore

	input:						.ascii "0000000000"


.section .text
	.global menChoice
	.type menChoice, @function
menChoice:

_print_menu:
	# Stampo header menu (una volta sola)
	movl $4, %eax
	movl $1, %ebx
	leal menu_header, %ecx
	movl menu_header_len, %edx
	int $0x80

	# Stampo il contenuto del menu (una volta sola)
	movl $4, %eax
	movl $1, %ebx
	leal menu_contenuto, %ecx
	movl menu_contenuto_len, %edx
	int $0x80


_start_loop:

_print_input_layout:
	# Stampo layout di input
	movl $4, %eax
	movl $1, %ebx
	leal menu_scelta, %ecx
	movl menu_scelta_len, %edx
	int $0x80

_input_scan:
	# Acquisisco la scelta
	movl $3, %eax				# Syscall scan
	movl $1, %ebx				# File descriptor (stdin)
	leal input, %ecx			# Destinazione 
	movl $10, %edx				# Lunghezza (imposto 10 per evitare eventuali overflow)
								# Presuppongo che non sia possibile inserire piu' di 10 cifre
	incl %edx					# Incremento EDX di 1 per il '\0'
	int $0x80					# Kernel interrupt

_validate_input:
	# Visto che si tratta di una stringa devo fare alcuni controlli
	leal input, %esi

	movb 1(%esi), %bl			# Sposto il secondo byte in AL
	cmpb $10, %bl				# Verifico che il secondo carattere sia il \n
	jne _stampa_errore			# Se not equal a \n allora ho un errore

	movb (%esi), %bl			# Sposto il primo byte in AL

	cmpb $49, %bl				# Verifico se il primo byte = 49 (cioe 1)
	je _hpf						# Se uguale salto al etichetta
	
	cmpb $50, %bl				# Verifico se il primo byte = 50 (cioe 2)
	je _edf						# Se uguale salto al etichetta

	cmpb $51, %bl				# Verifico se il primo byte = 51 (cioe 3)
	je _exit_code				# Se uguale salto al etichetta

_stampa_errore:
	# Se non corrisponde stampo errore e ricomincio il ciclo
	movl $4, %eax
	movl $1, %ebx
	leal menu_scelta_errore, %ecx
	movl menu_scelta_errore_len, %edx
	int $0x80

	jmp _start_loop				# Riparto dal etichetta

_hpf:
	# Imposto EAX a 1 (HPF)
	movl $1, %eax
	jmp _return

_edf:
	# Imposto EAX a 2 (EDF)
	movl $2, %eax
	jmp _return

_exit_code:
	# Imposto EAX a 0 (EXIT)
	movl $0, %eax

_return:
	ret
