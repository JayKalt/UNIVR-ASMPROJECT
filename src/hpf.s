# --------------- #
# filename: hpf.s #
# --------------- #

.section .text
	.global hpf
	.type hpf, @function
hpf:

_init:
	# Carico sullo stack EBP e lo libero
	pushl %ebp
	movl %esp, %ebp

	subl $1, 8(%ebp)

	# Azzero i registri indici
	xorl %ecx, %ecx
	xorl %edx, %edx

_loop1:
	# Recupero il valore nel indice i
	movl (%esi, %ecx, 4), %eax			# Ho indirizzo di i
	movl (%eax), %eax					# Ho il valore in indirizzo i

	# Preparo j
	movl %ecx, %edx						# Inizliazzo j = i
	incl %edx							# j++

_loop2:
	# Recupero il valore nel indice j
	movl (%esi, %edx, 4), %ebx			# Ho indirizzo di j
	movl (%ebx), %ebx					# Ho il valore in indirizzo j

_cmp_priority:
	# Faccio la compare con la priorita
	cmpl %eax, %ebx						# Confronto i due valori
	je _cmp_expiry						# Se sono uguali, confronto per scadenza
	jl _next_j							# Se campo[j] < campo[i], j++
	jg _swap							# Se campo[j] > campo[i], faccio lo swap

_cmp_expiry:
	# Faccio la compare con la scadenza
	movl (%esi, %ecx, 4), %eax			# Ricalcolo i
	subl $4, %eax						# Mi sposto nel campo corretto
	movl (%eax), %eax					# Ho il valore in indirizzo i

	movl (%esi, %edx, 4), %ebx			# Ricalcolo j
	subl $4, %ebx						# Mi sposto nel campo corretto
	movl (%ebx), %ebx					# Ho il valore in indirizzo j

	cmp %eax, %ebx						# Confronto i due valori
	je _cmp_prod_time					# Se sono uguali, confronto per tempo di produzione
	jl _swap							# Se campo[j] < campo[i], faccio lo swap
	jg _base_refresh					# Se campo[j] > campo[i], ripristino valore iniziale di i e j++

_cmp_prod_time:
	# Faccio la compare con il tempo di produzione
	movl (%esi, %ecx, 4), %eax			# Ricalcolo i
	subl $8, %eax						# Mi sposto nel campo corretto
	movl (%eax), %eax					# Ho il valore del indirizzo i

	movl (%esi, %edx, 4), %ebx			# Ricalcolo j
	subl $8, %ebx						# Mi sposto campo corretto
	movl (%ebx), %ebx					# Ho il valore del indirizzo j

	cmp %eax, %ebx						# Confronto i due valori
	jge _base_refresh					# Se sono uguali o campo[j] > campo[i], ripristino valore iniziale di i e j++
	jl _swap							# Se campo[j] < campo[i], faccio lo swap

_swap:
	movl (%esi, %ecx, 4), %eax			# Calcolo indirizzo indice i
	movl (%esi, %edx, 4), %ebx			# Calcolo indirizzo indice j 
	movl %eax, (%esi, %edx, 4)			# Swap indice i in indirizzo indice j
	movl %ebx, (%esi, %ecx, 4)			# Swap indice j in indirizzo indice i

_base_refresh:
	# Ripristino il valore del indirizzo i in EAX
	movl (%esi, %ecx, 4), %eax			# Ho indirizzo i
	movl (%eax), %eax					# Ho il valore in indirizzo i

_next_j:
	incl %edx							# j++
	cmp 8(%ebp), %edx					# Verifico j ok
	jle _loop2							# Se ok, continua loop2 

_next_i:
	incl %ecx							# Altrimenti i++
	cmp 8(%ebp), %ecx					# Verifico i ok
	jl _loop1							# Se ok, continua loop1

_end:
	popl %ebp							# Ripristino stack
	ret
