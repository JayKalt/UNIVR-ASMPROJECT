# ------------------- #
# filename: movToId.s #
# ------------------- #

.section .text
	.global movToId
	.type movToId, @function
movToId:

_start:
	# Verifico le condizioni del ciclo
	cmpb $0, %al			# Verifico se ho controllato tutti i prodotti
	je _all_good			# Se si, passo al etichetta
	subb $1, %al			# Altrimenti counter--

	subl %eax, (%esi)		# Decremento il contenuto di ESI di n byte (in EAX)
	addl $4, %esi			# Aggiorno ESI alla nuova posizione

	jmp _start				# Ritorna al loop iniziale

_all_good:
	ret
