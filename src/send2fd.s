# ------------------- #
# filename: send2fd.s #
# ------------------- #

#	
#	FAC SIMILE DEL OUTPUT ATTESO	
#
#	Pianificazione hpf_header:
#	12:0
#	4:17
#	Conclusione: 17
#	Penalty: 20
#

.section .text
	# Integers
	# -----------------------------------------------------------------------
	hpf_header:				.ascii "Pianificatore HPF:\n"
	hpf_header_len:			.long . - hpf_header
	edf_header:				.ascii "Pianificatore EDF:\n"
	edf_header_len:			.long . - edf_header
	# -----------------------------------------------------------------------
	conclusione:			.ascii "Conclusione: "
	conclusione_len:		.long . - conclusione
	penalty:				.ascii "Penalty: "
	penalty_len:			.long . - penalty
	# -----------------------------------------------------------------------

.section .data
	# Byte
	# -----------------------------------------------------------------------
	column:		.byte 58
	invio:		.byte 10

.section .text
	.global send2fd
	.type send2fd, @function
send2fd:

	pushl %ebp
	movl %esp, %ebp

_select_header:
	# Verifico algoritmo selezionato
	cmpb $1, 20(%ebp)
	jne _edf_header

_hpf_header:
	# Stampo header per HPF
	movl $4, %eax
	movl 8(%ebp), %ebx
	leal hpf_header, %ecx
	movl hpf_header_len, %edx
	int $0x80
	jmp _register_set_up

_edf_header:
	# Stampo header per EDF
	movl $4, %eax
	movl 8(%ebp), %ebx
	leal edf_header, %ecx
	movl edf_header_len, %edx
	int $0x80

# --------------------------------------------------------------
# Da qui in poi inizio la stampa delle coppie ID:TEMPO_DI_INIZIO

_register_set_up:
	pushl $0					# Salvo sullo stack il tempo iniziale di produzione

_loop1:
	cmpl $0, 16(%ebp)			# Verifico che counter ok
	jle _loop_exit				# Altrimenti passo a ripristinare lo stack e quindi ESP
	subb $1, 16(%ebp)			# counter--

	# Stampa del ID prodotto
	movl (%esi), %edi			# Sposto indirizzo di ID in EDI
	movl (%edi), %eax			# Sposto ID in EAX

	call itoa

	# Stampa del carattere ':'
	movl $4, %eax
	movl 8(%ebp), %ebx
	leal column, %ecx
	movl $1, %edx
	int $0x80

	# Stampa del tempo di inizio del prodotto
	movl (%esp), %eax			# Carico in EAX il contenuto di ESP (il tempo iniziale di produzione)
	call itoa
	movl 4(%edi), %eax			# Salvo il tempo di produzione del prodotto corrente
	addl %eax, (%esp)			# E faccio la add a ESP (il tempo iniziale di produzione)

	# Stampa del carattere '\n'
	movl $4, %eax
	movl 8(%ebp), %ebx
	leal invio, %ecx
	movl $1, %edx
	int $0x80

_next:
	# Passo al prossimo prodotto
	addl $4, %esi				# i++
	jmp _loop1

# --------------------------------------------------------------

_loop_exit:

_print_final_t:
	# Stampo il tempo finale
	movl $4, %eax
	movl 8(%ebp), %ebx
	leal conclusione, %ecx
	movl conclusione_len, %edx
	int $0x80

	# Salvo il valore di t.finale in EAX e lo stampo
	movl (%esp), %eax
	call itoa

	# Stampa del carattere '\n'
	movl $4, %eax
	movl 8(%ebp), %ebx
	leal invio, %ecx
	movl $1, %edx
	int $0x80

_print_penalty:
	# Stampa della penalty complessiva
	movl $4, %eax
	movl 8(%ebp), %ebx
	leal penalty, %ecx
	movl penalty_len, %edx
	int $0x80

	# Salvo il vlaore della penalty in EAX e lo stampo
	movl 12(%ebp), %eax
	call itoa

	# Stampa del carattere '\n'
	movl $4, %eax
	movl 8(%ebp), %ebx
	leal invio, %ecx
	movl $1, %edx
	int $0x80


	# Ripristino lo stack (non mi serve piu il valore in ESP)
	popl %ebp
	popl %ebp
	ret
