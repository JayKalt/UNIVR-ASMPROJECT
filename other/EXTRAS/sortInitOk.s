# ------------------------ #
# filename: sortInitOk.s #
# ------------------------ #

.section .data
	messaggio_ok:			.ascii	"\n\n[v] Inizializzazione variabili sort\n"
	messaggio_ok_len:		.long . - messaggio_ok

.section .text
	.global sortInitOk
	.type sortInitOk, @function
sortInitOk:
	
	movl $4, %eax
	movl $1, %ebx
	leal messaggio_ok, %ecx
	movl messaggio_ok_len, %edx
	int $0x80

	ret
