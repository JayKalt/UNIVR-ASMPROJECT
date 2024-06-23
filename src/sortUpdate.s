# ---------------------- #
# filename: sortUpdate.s #
# ---------------------- #

.section .text
	.global sortUpdate
	.type sortUpdate, @function
sortUpdate:

	xorl %eax, %eax

_loop1:
	cmpb $0, %cl					# Verifico se ho controllato tutti i prodotti
	jle _all_good					# Se si, passo al etichetta

	# Riporto gli indirizzi al campo ID
	movl (%esi, %eax, 4), %edi		# Sposto il contenuto di ESI + OFF-SET in EDI
	subl %edx, %edi					# Mi sposto al inidrizzo del ID
	movl %edi, (%esi, %eax, 4)		# Salvo indirizzo del ID in ESI + OFF-SET

	incb %al						# Aumento EAX di 1 byte
	loop _loop1

_all_good:
	ret
