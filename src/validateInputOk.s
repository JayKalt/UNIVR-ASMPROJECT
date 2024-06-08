# --------------------------- #
# filename: validateInputOk.s #
# --------------------------- #

.section .data
	messaggio_ok:			.ascii	"[v] Validazione input\n"
	messaggio_ok_len:		.long . - messaggio_ok

.section .text
	.global validateInputOk
	.type validateInputOk, @function
validateInputOk:
	
	movl $4, %eax
	movl $1, %ebx
	leal messaggio_ok, %ecx
	movl messaggio_ok_len, %edx
	int $0x80

	ret
