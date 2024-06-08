# --------------------- #
# filename: sort_init.s #
# --------------------- #

.section .text
	.global sort_init
	.type sort_init, @function
sort_init:

_start:

	# Verifico le condizioni del ciclo
	cmpb $0, %al			# Verifico se ho controllato tutti i prodotti
	je _all_good			# Se si, passa al etichetta
	subb $1, %al			# Altrimenti continuo e decremento il counter

	movl (%esi), %ebx		# Sposto il contenuto del array sorgente prodotto in EBX
	movl %ebx, (%edi)		# Sposto EBX nel array di destinazione 

_loop:
	# Incremeneto al ID successivo entrambi gli array e riprendo il ciclo
	addl $16, %esi			# Salto tutti gli altri parametri
	addl $4, %edi			# Passo alla cella di memoria sucessiva
	jmp _start				# Ritorna al loop iniziale

_all_good:
	# Arrivato a questo punto ho letto tutti i valori con successo
	# Posso quindi abbassare la flag e ritornare al main
	movl $0, 4(%esp)		# Sposto il valore della return
	ret
	