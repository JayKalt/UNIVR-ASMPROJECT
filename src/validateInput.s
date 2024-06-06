# ----------------------- #
# filename: validateInput #
# ----------------------- #

.section .text
	.global validateInput
	.type validateInput, @function
validateInput:

	movl %esp, %ebp
	pushl %ebp

	