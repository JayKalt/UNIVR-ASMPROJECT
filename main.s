# ---------------- #
# filename: main.s #
# ---------------- #


.section .data
	filename_pointer: .int		# Filename pointer
	fd: .int 0					# File descriptor
	buffer: .string ""			# Spazio per buffer input
	newline: .byte 10			# Valore simbolo nuova linea
	pord_num:	.int 0			# Numero del prodotto

.section .bss

.section .text
	.global _start

_opne:
    # Salvo il nome del file
	popl %ecx					# Numero di argomenti passati al programma
	cmp $2, %ecx				# Verifica se è stato passato almeno un argomento
	jne _exit					# Se non ci sono argomenti, esci
	popl %ecx					# Puntatore al primo argomento (nome del programma)
	popl filename_pointer		# Puntatore al secondo argomento (nome del file)

	# Apro il file
	movl $5, %eax					# Syscall file open
	movl filename_pointer, %ebx		# Nome del file
	movl $0, %ecx					# Modalita' di apertura del file (O_RDONLY)
	int $0x80						# Kernel interrupt

	# Se si verifica un errore esco
	cmp $0, %eax
	jl _exit						# Salta alla fine del programma

	# Altrimenti...
	movl %eax, fd					# Salva il file descriptor in fd e continua

_read_loop:
	# Leggo il file
	movl $3, %eax			# Syscall read
	movl fd, %ebx			# File descriptor
	movl $buffer, %ecx		# Buffer di input
	movl $1, %edx			# Lunghezza massima
	int $0x80				# Kernel interrupt

	cmp $0, %eax			# Verifico no errori / EOF
	jle _close_file			# E in caso chiudo il file

	# Controllo se ho una nuova linea
	movb buffer, %al		# Copio il carattere nel buffer in AL
	cmpb newline, %al		# Comparo il carattere con '\n'
	jne _print_line			# Se sono diversi stampo il carattere
	incw pord_num			# Altrimenti incremento il counter

_print_line:
	# Stampa il contenuto della riga
	movl $4, %eax			# Syscall write
	movl $1, %ebx			# File descriptor stdout (terminale)
	movl $buffer, %ecx		# Buffer di output
	int $0x80				# Kernel interrupt

	jmp _read_loop			# Ricomincia la lettura file



_close_file: 
	# Chiudo il file
	movl $6, %eax			# Syscall close
	movl %ebx, %ecx			# File descriptor da chiudere
	int $0x80				# Kernel interrupt 

_exit:
	# Uscita programma
	movl $1, %eax			# Syscall exit
	xorl %ebx, %ebx			# Codice di usita 0
	int $0x80				# Kernel interrupt

_start:
	jmp _opne				# Passa ad open
	jmp _exit				# Passa ad exit
