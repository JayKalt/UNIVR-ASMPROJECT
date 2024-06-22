# ------------------------- #
# filename: validateInput.s #
# ------------------------- #

#	_____________________________________________________________
# 	|	nome parametro	|	valore minimio	|	valore massimo	|
#	|		id			|		  1			|		 127		|
#	|	t. produzione	|		  1			|		  10		|
#	|	  scadenza		|		  1			|		 100		|
#	|	  priorita		|		  1			|		   5		|
#	|___________________________________________________________|
#

.section .text
	.global validateInput
	.type validateInput, @function
validateInput:

_start:
	# Verifico le condizioni del ciclo
	cmpb $0, %al			# Verifico se ho controllato tutti i prodotti
	je _all_good			# Se si, passa al etichetta
	subb $1, %al			# Altrimenti continuo e decremento il counter



# Da qui in avanti inizia una cascata di istruzioni per la verifica
# dei valori in ciasuno dei parametri di un prodotto.

_id_validate:
	cmpb $1, (%esi)			# Comparo il parametro con il primo valore atteso
	jge _max_id				# Se va a buon fine continuo
	ret						# Altrimenti faccio la return senza modificare la flag
_max_id:
	cmpb $127, (%esi)		# Comparo il parametro con il secondo valore atteso
	jle _time_validate		# Se va a buon fine passo al prossimo parametro
	ret						# Altrimenti faccio la return senza modificare la flag

_time_validate:
	# Mi sposto al campo successivo
	addl $4, %esi
_min_time:
	cmpb $1, (%esi)
	jge _max_time
	ret
_max_time:
	cmpb $10, (%esi)
	jle _exp_validate
	ret

_exp_validate:
	# Mi sposto al campo successivo
	addl $4, %esi
_min_exp:
	cmpb $1, (%esi)
	jge _max_exp
	ret
_max_exp:
	cmpb $100, (%esi)
	jle _prior_validate
	ret

_prior_validate:
	# Mi sposto al campo successivo
	addl $4, %esi
_min_prior:
	cmpb $1, (%esi)
	jge _max_prior
	ret
_max_prior:
	cmpb $5, (%esi)
	jle _loop
	ret

_loop:
	# Mi sposto al ID successivo e riprendo il ciclo
	addl $4, %esi
	jmp _start

_all_good:
	# Arrivato a questo punto ho letto tutti i valori con successo
	# Posso quindi abbassare la flag e ritornare al main
	movl $0, 4(%esp)
	ret
