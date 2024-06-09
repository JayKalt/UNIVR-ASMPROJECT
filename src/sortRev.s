# ------------------- #
# filename: sortRev.s #
# ------------------- #

.section .text
	.global sortRev
	.type sortRev, @function
sortRev:

	xorl %ecx, %ecx
	subb $1, %al

_loop:
	#
	addl $4, (%esi, %ecx, 4)

	# Verifico le condizioni del ciclo
	cmpb %al, %cl
	je _all_good
	incb %cl

	jmp _start				# Ritorna al loop iniziale

_all_good:
	# 
	# 
	movl $0, 4(%esp)		# Sposto il valore della return
	ret
