# ------------------------ #
# filename: parametersOk.s #
# ------------------------ #

.section .data
	messaggio_ok:			.ascii	"[v] Acquisizione parametri\n"
	messaggio_ok_len:		.long . - messaggio_ok

.section .text
	.global parametersOk
	.type parametersOk, @function
parametersOk:
	
	movl $4, %eax
	movl $1, %ebx
	leal messaggio_ok, %ecx
	movl messaggio_ok_len, %edx
	int $0x80

	ret
