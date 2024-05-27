# --------------------- #
# filename: read_loop.s #
# --------------------- #

.section .data
	fd:					.int 0			# File descriptor
	buffer:				.string ""		# Spazio per buffer input
	newline:			.byte 10		# Valore simbolo nuova linea
	counter:			.int 0			# Numero dei prodotti contati con il '\n'

.section .text
	.global read_loop
	.type read_loop, @function
read_loop:

	movl %eax, fd					# Salvo il file descriptor preso dal main in fd

_read_loop:
	# Leggo il file
	movl $3, %eax					# Syscall read
	movl fd, %ebx					# File descriptor
	movl $buffer, %ecx				# Buffer di input
	movl $1, %edx					# Lunghezza massima
	int $0x80						# Kernel interrupt

	cmp $0, %eax					# Verifico no errori / EOF
	jle _return						# E in caso chiudo il file

	# Controllo se ho una nuova linea
	movb buffer, %al				# Copio il carattere nel buffer in AL
	cmpb newline, %al				# Comparo il carattere con '\n'
	jne _print_line					# Se sono diversi stampo il carattere
	incw counter					# Altrimenti incremento il counter

_print_line:
	# Stampa il contenuto della riga
	movl $4, %eax					# Syscall write
	movl $1, %ebx					# File descriptor stdout (terminale)
	movl $buffer, %ecx				# Buffer di output
	int $0x80						# Kernel interrupt

	jmp _read_loop					# Ricomincia la lettura file

_return:
	movl counter, %eax
	ret
