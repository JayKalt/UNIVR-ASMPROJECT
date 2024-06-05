# ---------------- #
# filename: atoi.s #
# ---------------- #

.section .text
	.global atoi
	.type atoi, @function
atoi:

	movl %esp, %ebp					# Sposto ESP in EBP
	pushl %ebp						# Salvo EBP
	
	subl $48, %eax					# Sottraggo 48 per ottenere il valore decimale
	movl %eax, %ebx					# Salvo temporaneamente il valore in EBX

	movl 4(%ebp), %eax				# Sposto 4(EBP) cioe il contenuto della variabile pushata in EAX
	movb $10, %dl					# Sposto il moltiplicatore in DL
	mulb %dl						# Moltiplico la variabile

	addl %ebx, %eax					# Aggiungo il valore decimale a Result
	movl %eax, 4(%ebp)				# Salvo il risultato

	popl %ebp						# Ripristino EBP
	ret								# Return
