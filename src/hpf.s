# --------------- #
# filename: hpf.s #
# --------------- #

.section .text
	.global hpf
	.type hpf, @function
hpf:

_init:
	# Carico sullo stack EBP e lo libero
	movl %esp, %ebp
	pushl %ebp

	# Azzero i registri indici
	xorl %ecx, %ecx
	xorl %edx, %edx

	# Decremento di 1 indice massim
	subl $1, 4(%ebp)

_loop1:
	# Verifico che indice BASE < indice massimo
	cmp 4(%ebp), %ecx
	jge _end

	# Recupero il valore del indirizzo e lo salvo in EAX
	movl (%esi, %ecx, 4), %eax			# Ho indirizzo BASE
	movl (%eax), %eax					# Ho il valore del indirizzo BASE

	# Preparo BASE + OFF-SET
	movl %ecx, %edx						# Inizliazzo BASE + OFF-SET a BASE
	incl %edx							# Incremeneto OFF-SET

_loop2:
	# Verifico se posso fare uno swap tra BASE e BASE + OFF-SET

	# Recupero il valore di BASE + OFF-SET
	movl (%esi, %edx, 4), %ebx			# Ho indirizzo BASE + OFF-SET
	movl (%ebx), %ebx					# Ho il valore del indirizzo BASE + OFF-SET

_cmp_priority:
	# Faccio la compare con la priorita
	cmpl %eax, %ebx						# Confronto i due valori
	je _cmp_expiry						# Se sono uguali, confronto per scadenza
	jl _next_off						# Se (BASE + OFF-SET) < (BASE), salto al prossimo OFF-SET
	jg _swap							# Se (BASE + OFF-SET) > (BASE), faccio lo swap

_cmp_expiry:
	# Faccio la compare con la scadenza
	movl (%esi, %ecx, 4), %eax			# Ricalcolo BASE
	subl $4, %eax						# Mi sposto sulla scadenza
	movl (%eax), %eax					# Ho il valore del indirizzo BASE

	movl (%esi, %edx, 4), %ebx			# Ricalcolo BASE + OFF-SET
	subl $4, %ebx						# Mi sposto sulla scadenza
	movl (%ebx), %ebx					# Ho il valore del indirizzo BASE + OFF-SET

	cmp %eax, %ebx						# Confronto i due valori
	je _cmp_prod_time					# Se sono uguali, confronto per tempo di produzione
	jl _swap							# Se (BASE + OFF-SET) < (BASE), faccop lo swap
	jg _cmp_prod_time					# Se (BASE + OFF-SET) > (BASE), salto al prossimo OFF-SET 

_cmp_prod_time:
	# Faccio la compare con il tempo di produzione
	movl (%esi, %ecx, 4), %eax			# Ricalcolo BASE
	subl $8, %eax						# Mi sposto sul tempo di produzione
	movl (%eax), %eax					# Ho il valore del indirizzo BASE

	movl (%esi, %edx, 4), %ebx			# Ricalcolo OFF-SET
	subl $8, %ebx						# Mi sposto sul tempo di produzione
	movl (%ebx), %ebx					# Ho il valore del indirizzo OFF-SET

	cmp %eax, %ebx						# Confronto i due valori
	jge _next_off						# Se sono uguali o (BASE + OFF-SET) > (BASE), salto al prossimo OFF-SET
	jl _swap							# Se (BASE + OFF-SET) < (BASE), faccio lo swap

_swap:
	movl (%esi, %ecx, 4), %eax			# Sposto in EAX BASE
	movl (%esi, %edx, 4), %ebx			# Sposto in EBX OFF-SET
	movl %eax, (%esi, %edx, 4)			# Sposto BASE in OFF-SET
	movl %ebx, (%esi, %ecx, 4)			# Sposto OFF-SET in BASE

_next_off:
	incl %edx							# Incremento OFF-SET
	cmp 4(%ebp), %edx					# Verifico che OFF-SET sia ok
	jl _loop2							# Se ok, continua loop2 

	incl %ecx							# Altrimenti passa alla prossima BASE
	jmp _loop1							# Ricomincia loop1

_end:
	popl %ebp
	ret