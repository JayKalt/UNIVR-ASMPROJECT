# ---------------------- #
# filename: fileOpenOk.s #
# ---------------------- #

.section .data
	messaggio_ok:			.ascii	"[v] Apertura file\n"
	messaggio_ok_len:		.long . - messaggio_ok

.section .text
	.global fileOpenOk
	.type fileOpenOk, @function
fileOpenOk:
	
	movl $4, %eax
	movl $1, %ebx
	leal messaggio_ok, %ecx
	movl messaggio_ok_len, %edx
	int $0x80

	ret
