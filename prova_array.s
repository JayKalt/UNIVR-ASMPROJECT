.section .data
	filename:			.ascii "input.txt"
	fd:					.int 0			# File descriptor
	
	newline:			.byte 10		# Valore simbolo nuova linea
	comma:				.byte 44		# Valore simbolo virgola

	result:				.int 0			# Risultato da salvare
	format:				.string "%d\n"
	counter:			.int 0			# Numero dei prodotti contati con il '\n'

	error_string:		.ascii "Errore apertura file\n"
	error_string_len:	.long . - error_string

.section .bss
	buffer:				.string ""		# Spazio per buffer input

.section .text
	.global _start
_start:

	# apro file lettura
	movl $5, %eax
	movl $filename, %ebx
	xorl %ecx, %ecx
	int $0x80

	# Salvo il file descriptor preso dal main in fd
	cmp $0, %eax
	jl _exit_error

	movl %eax, fd

_read_loop:
	# Leggo il file
	movl $3, %eax					# Syscall read
	movl fd, %ebx					# File descriptor
	movl $buffer, %ecx				# Buffer di input
	movl $1, %edx					# Lunghezza massima
	int $0x80						# Kernel interrupt

	cmp $0, %eax					# Verifico no errori / EOF
	jle _close_file					# E in caso chiudo il file

	# Sposto il carattere in AL
	movl buffer, %eax				# Copio il carattere nel buffer in AL

	# Controllo se ho una nuova linea
	cmpb newline, %al				# Comparo il carattere con '\n'
	je _new_line					# Se coincide salto alla etichetta indicata

	# Controllo se ho una virgola
	cmpb comma, %al					# Comparo il carattere con ','
	je _reset						# Se coincide salto alla etichetta indicata

	# Chiamo la funzione atoi
	pushl result					# Salvo il valore di result nello stack
	call atoi						# Chiamo la funzoine
	popl result						# Salvo il risultato in result

	jmp _read_loop

_new_line:
	incw counter					# Incremento il counter
_reset:
	# Resetto il contenuto di result
	movl $0, result
	jmp _read_loop

_close_file:
	movl $6, %eax
	xorl %ebx, %ebx
	int $0x80
	jmp _exit

_exit_error:
	movl $4, %eax
	movl $1, %ebx
	leal error_string, %ecx
	movl error_string_len, %edx
	int $0x80

_exit:
	# Esco dal programma
	movl $1, %eax					# Syscall exit
	xorl %ebx, %ebx					# Codice di usita 0
	int $0x80						# Kernel interrupt


.type atoi, @function
atoi:
	movl %esp, %ebp
	pushl %ebp
	
	subl $48, %eax
	movl %eax, %ebx	

	movl 4(%ebp), %eax
	movb $10, %dl
	mulb %dl

	addl %ebx, %eax
	movl %eax, 4(%ebp)				# Salvo il risultato

	popl %ebp
	ret
