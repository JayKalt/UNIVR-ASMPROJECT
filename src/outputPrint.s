# ----------------------- #
# filename: outputPrint.s #
# ----------------------- #

#	
#	FAC SIMILE SCRITTURA	
#
#	Pianificazione HPF:
#	12:0
#	4:17
#	Conclusione: 17
#	Penalty: 20
#

.section .text
	# Strings
	hpf:				.ascii "Pianificatore HPF:\n"
	hpf_len:			.long . - hpf
	edf:				.ascii "Pianificatore EDF:\n"
	edf_len:			.long . - edf

	conclusione:		.ascii "Conclusione: "
	conclusione_len:	.long . - conclusione
	penalty:			.ascii "Penalty: "
	penalty_len:		.long . - penalty


.section .data
	column:		.byte 58
	invio:		.byte 10

.section .text
	.global outputPrint
	.type outputPrint, @function
outputPrint:
	
	cmp $1, %eax
	jne _edf

	# 
	movl $4, %eax
	movl $1, %ebx
	leal hpf, %ecx
	movl hpf_len, %edx
	int $0x80
	jmp _set_up

_edf:
	#
	movl $4, %eax
	movl $1, %ebx
	leal edf, %ecx
	movl edf_len, %edx
	int $0x80

_set_up:
	pushl %ebp
	movl %esp, %ebp

	xorl %eax, %eax
	pushl %eax

_loop1:
	cmpl $0, 16(%ebp)
	jle _end

	# ..............
	movl (%esi), %edi			# Sposto indirizzo di ID in EDI
	movl (%edi), %eax			# Sposto ID in EAX
	call itoa

	# ..............
	movl $4, %eax
	movl $1, %ebx
	leal column, %ecx
	movl $1, %edx
	int $0x80

	# ..............
	popl %eax
	movl 4(%edi), %ebx			# Incremento il tempo di produzione
	addl %ebx, %eax				# Sposto il valore in EAX
	pushl %eax
	call itoa

	# ..............
	movl $4, %eax
	movl $1, %ebx
	leal invio, %ecx
	movl $1, %edx
	int $0x80

_next:
	addl $4, %esi
	subb $1, 16(%ebp)
	jmp _loop1

_end:
	addl $4, %esp

	movl $4, %eax
	movl $1, %ebx
	leal conclusione, %ecx
	movl conclusione_len, %edx
	int $0x80

	movl 8(%ebp), %eax
	call itoa

	# ..............
	movl $4, %eax
	movl $1, %ebx
	leal invio, %ecx
	movl $1, %edx
	int $0x80

	movl $4, %eax
	movl $1, %ebx
	leal penalty, %ecx
	movl penalty_len, %edx
	int $0x80

	movl 12(%ebp), %eax
	call itoa

	# ..............
	movl $4, %eax
	movl $1, %ebx
	leal invio, %ecx
	movl $1, %edx
	int $0x80

	popl %ebp
	ret
