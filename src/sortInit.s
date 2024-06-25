# -------------------- #
# filename: sortInit.s #
# -------------------- #

.section .text
	.global sortInit
	.type sortInit, @function
sortInit:

_start:
	# Verifico le condizioni del ciclo
	cmpb $0, %al			# Verifico se ho controllato tutti i prodotti
	je _ret					# Se si, return
	subb $1, %al			# Altrimenti counter--

	movl %esi, (%edi)		# Sposto indirizzo di ESI nel contenuto del indirizzo di EDI
							# ovvero sposto indirizzo del parametro del array sorgente nel
							# indice del array di destinazione

	# Incremeneto al ID successivo entrambi gli array e riprendo il ciclo
	addl $16, %esi			# Salto tutti gli altri parametri
	addl $4, %edi			# Passo alla cella di memoria sucessiva
	jmp _start				# Ritorna al loop iniziale

_ret:
	# Arrivato a questo punto ho letto tutti i valori con successo
	ret
