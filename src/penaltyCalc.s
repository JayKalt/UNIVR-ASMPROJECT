# ----------------------- #
# filename: penaltyCalc.s #
# ----------------------- #

#
#	+---------------------------------------------------------------+
#	|						CALCOLO PENALTY							|
#	|	Fromule utili:												|
#	|																|
#	|	1.	t. trascorso	=	t.trascorso + t.produzione			|
#	|	2.	prod. penalty	=	(t.trascorso - scadenza) * priorita	|
#	|	3.	tot. penalty	=	tot. penalty + prod. penalty 		|
#	|																|
#	+---------------------------------------------------------------+
#

.section .text
	.global penaltyCalc
	.type penaltyCalc, @function
penaltyCalc:

_loop1:
	cmp $0, %ecx				# Verifico se ho letto tutti i prodotti
	jle _return

	movl (%esi), %edi			# Recupero indirizzo del primo prodotto
	movl 4(%edi), %eax			# produzione  -->	in EAX
	movl 8(%edi), %ebx			# scadenza	  -->	in EBX
	movl 12(%edi), %edx			# priorita	  -->	in EDX

	addl %eax, 4(%esp)			# Aggiorno il totale del tempo trascorso secondo
								# la formula 1

	cmp 4(%esp), %ebx			# Verifico che la scadenza non superi il tempo trascorso
	jl _add_penalty				# Se scadenza < totale tempo trascorso ho una penalty
	jmp _next					# Altrimenti posso passare al prodotto successivo

_add_penalty:
	# Calcolo la penality relativa ad un prodotto specifico secondo la formula 2
	movl 4(%esp), %eax			# Carico il tempo totale trascorso in EAX
	subl %ebx, %eax				# EAX = EAX - EBX = t.trascorso - scadenza
	mull %edx					# moltiplico per EDX ovvero la priorita

_update_total_penalty:
	# Aggiorno la penalty complessiva
	addl %eax, 8(%esp)			# Aggiungo alla penalty la nuova penalty

_next:
	# Passo al prodotto successivo
	addl $4, %esi
	loop _loop1

_return:
	ret
