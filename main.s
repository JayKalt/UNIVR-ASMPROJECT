.section .data
	new_line_char:	.byte 10
	input_file: .string ""


.section .text
	.global _start
_start:
	movl %esp, %ebp
	addl $8, %esp
	leal input_file, %eax
	movl (%esp), %eax
	
	call stampa
	
	movl $1, %eax
	movl $0, %ebx
	int $0x80
	
.type stampa_parametro, @function
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %ecx
	
	xorl %edx, %edx
	
conteggio_caratteri:
	
	movb (%ecx, %edx), %al
	
	jz fine_conteggio:
	
	incl %edx
	jmp conteggio_caratteri

finito_conteggio:
	movl $4, %eax
	movl $1, %ebx
	
	int $0x80
	movl $4, %eax
	movl $1, %ebx
	leal new_line_char, %ecx
	
	movl $1, %edx
	int $0x80
	
	movl %ebp, %esp
	popl %ebp
	ret
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	