# --------------------- #
# filename: itoa.s #
# --------------------- #

.section .data
	char: .byte 0			# la variabile char e' dichiarata di tipo byte

.section .text
	.global itoa
	.type itoa, @function
itoa:  
	pushl %ebp
	movl %esp, %ebp

	movl   $0, %ecx		# charica il numero 0 in %ecx


continua_a_dividere:

	cmpl   $10, %eax	# confronta 10 con il contenuto di %eax

	jge dividi			# salta all'etichetta dividi se %eax e'
						# maggiore o uguale a 10

	pushl %eax			# salva nello stack il contenuto di %eax
	incl   %ecx			# incrementa di 1 il valore di %ecx per
						# contare quante push eseguo;
						# ad ogni push salvo nello stack una cifra 
						# del numero (a partire da quella meno
						# significativa)

	movl  %ecx, %ebx	# copia in %ebx il valore di %ecx
						# il numero di cifre che sono state 
						# charicate nello stack

	jmp stampa			# salta all'etichetta stampa


dividi:

	movl  $0, %edx		# charica il numero 0 in %edx

	movl $10, %ebx		# charica il numero 10 in %ebx

	divl  %ebx			# divide per %ebx (10) il numero ottenuto 
						# concatenando il contenuto di %edx e %eax 
						# (notare che in questo caso %edx=0)
						# il quoziente viene messo in %eax,
						# il resto in %edx

	pushl  %edx			# salva il resto della divisione nello stack

	incl   %ecx			# incrementa il contatore delle cifre 
						# salvate nello stack

	jmp	continua_a_dividere 

	
stampa:

	cmpl   $0, %ebx		# controlla se ci sono ancora charatteri da 
						# stampare

	je fine_itoa		# se %ebx=0 ho stampato tutto salto alla 
						# fine della funzione

	popl  %eax			# preleva l'elemento da stampare dallo stack

	movb  %al, char		# memorizza nella variabile char il valore 
						# contenuto negli 8 bit meno significativi 
						# del registro %eax; gli altri bit del 
						# registro non ci interessano visto che una 
						# cifra decimale e' contenuta in un solo 
						# byte

	addb  $48, char		# somma al valore char il codice ascii del 
						# charattere 0 (zero)
  
	decl   %ebx			# decrementa di 1 il numero di cifre da 
						# stampare
  
	pushw %bx			# salviamo il valore di %bx nello stack 
						# poiche' per effettuare la stampa dobbiamo 
						# modifichare i valori dei registri come 
						# richiesto dalla funzione del sistema 
						# operativo write

	movl   $4, %eax
	movl 20(%ebp), %ebx
	leal  char, %ecx		
	movl    $1, %edx
	int $0x80

	popw   %bx			# recupera il contatore dei charatteri da 
						# stampare salvato nello stack prima della 
						# chiamata alla funzione write
  
	jmp   stampa		# ritorna all'etichetta stampa per stampare 
						# il prossimo charattere. Notare che il 
						# blocco diistruzioni compreso tra 
						# l'etichetta stampa e l'istruzione jmp 
						# stampa e' un classico esempio di come 
						# creare un ciclo while in assembly


fine_itoa:
	popl %ebp
	ret
