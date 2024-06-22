# ---------------------- #
# filename: mainUpdate.s #
# ---------------------- #

.section .text
	.global mainUpdate
	.type mainUpdate, @function
mainUpdate:

	xorl %ebx, %ebx			# Azzero EBX per sicurezza

_loop1:
	# Verifico le condizioni del ciclo
	cmpb $0, %al			# Verifico se ho controllato tutti i prodotti
	jle _all_good			# Se si, passo al etichetta
	subb $1, %al			# Altrimenti counter--

	xorl %ecx, %ecx			# Azzero ECX per il loop2
	subl %edx, (%esi)		# Decremento il contenuto di ESI di n byte
							# Sto puntando al indirizzo ID

_loop2:
	# Sovrascrivo i valori del array principale con i nuovi valori
	cmpb $4, %ecx					# Verifico che il counter sia ok
	jge _continue					# Se no torno al loop1

	movl (%esi, %ecx, $4), %ebx		# Salvo indirizzo ID in EDX
	movl (%ebx), %ebx				# Sovrascrivo EDX con il contenuto di EDX (indirizzo ID)
	movl %ebx, (%edi, %ecx, $4)		# Sposto ID in indirizzo di EDI

	loop _loop2						# Ritorna al loop iniziale

_continue:
	addl $4, %esi			# Aggiorno ESI alla nuova posizione
	addl $16, %edi			# Aggiorno EDI alla nuova posizione
	jmp _loop1

_all_good:
	ret
