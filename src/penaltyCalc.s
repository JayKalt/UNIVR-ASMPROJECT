# ------------------- #
# filename: penaltyCalc.s #
# ------------------- #

#
#	CALCOLO PENALTY:
#
#		t. trascorso	=	t.trascorso + t.produzione
#		prod. penalty	=	(scadenza - t.trascorso) * priorita
#		tot. penalty	=	tot. penalty + prod. penalty 
#

.section .text
	.global penaltyCalc
	.type penaltyCalc, @function
penaltyCalc:

_loop1:
	cmp $0, %ecx
	jle _end

	movl (%esi), %edi			# inidrizzo id
	movl 4(%edi), %eax			# tempo produzione
	movl 8(%edi), %ebx			# scadenza
	movl 12(%edi), %edx			# priorita

	addl %eax, 4(%esp)			# ++totale tempo trascroso

	cmp 4(%esp), %ebx
	jl _add_penalty				# se scadenza > tempo complessivo allora penalita
	jmp _next

_add_penalty:
	movl 4(%esp), %eax			# tempo trascorso -> eax
	subl %ebx, %eax				# scadenza - tempo trascorso = numero da moltiplicare
	mull %edx					# moltiplico per la priorita
	addl %eax, 8(%esp)			# risultato della mull in penalty complessiva

_next:
	addl $4, %esi
	loop _loop1

_end:
	ret
