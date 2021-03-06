#-------------------------------
# Branch De-Offsetting - Marking Common File
# Author: Taylor Lloyd
# Date: July 18, 2012
#
#-------------------------------

.data
	.align 2
binary:
	.space 2052
noFileStr:
	.asciiz "Couldn't open specified file.\n"
nlStrCom:
	.asciiz "\n"
pointerStorage:
	.word 0x00

str_bgez:   .asciiz "bgez"
str_bgezal: .asciiz "bgezal"
str_bltz:   .asciiz "bgezal"
str_bltzal: .asciiz "bltzal"
str_beq:    .asciiz "beq"
str_bne:    .asciiz "bne"
str_blez:   .asciiz "blez"
str_bgtz:   .asciiz "bgtz"
str_space:  .asciiz " "
str_dollar: .asciiz "$"
str_comma:  .asciiz ","
str_hex:    .asciiz "0x"





.text
.globl disassembleBranch # Make disassembleBranch into a global symbol so it
                         # it can be used as a breakpoint

main:
	lw	$a0 4($a1)	# Put the filename pointer into $a0
	li	$a1 0		# Read Only
	li	$a2 0		# No Mode Specified
	li	$v0 13		# Open File
	syscall
	bltz	$v0 main_err	# Negative means open failed

	move	$a0 $v0		#point at open file
	la	$a1 binary	# write into my binary space
	li	$a2 2048	# read a file of at max 2kb
	li	$v0 14		# Read File Syscall
	syscall
	la	$t0 binary
	add	$t0 $t0 $v0	#point to end of binary space

	li	$t1 0xFFFFFFFF	#Place ending sentinel
	sw	$t1 0($t0)

	la	$a0 binary
	main_loop:
		#Check for ending sentinel
		lw	$t0 0($a0)
		li	$t1 -1
		beq	$t0 $t1 main_done

		#run student output code
		sw	$a0 pointerStorage
		jal	disassembleBranch

		#print newline
		la	$a0 nlStrCom
		li	$v0 4
		syscall

		#reload and increment $a0
		lw	$a0 pointerStorage
		addi	$a0 $a0 4
		j	main_loop
	
	main_err:
		la	$a0 noFileStr
		li	$v0 4
		syscall
	main_done:
		li	$v0 10
		syscall

disassembleBranch:
# copy $a0 to $t9
# $t9 now holds the same value of $a0 (address)
move    $t9, $a0
# same
addi    $t9, $a0, 0

# load instruction value
lw $t0, 0($t9) # read memory at address = $t9, load content to $t0

# saving parts of the instruction to different registers
srl     $t8, $t0, 26    # save opcode to $t8

# save rs to $t7
sll     $t7, $t0, 6
srl     $t7, $t7, 27

# save rt to $t6
sll     $t6, $t0, 11
srl     $t6, $t6, 27

# read immediate
# sll     $t5, $t0, 16
# sra     $t5, $t5, 16
# addi    $t5, $t5, 1
# sll     $t5, $t5, 2
# read immediate to address offset
sra     $t5, $t0, 14
addi    $t5, $t5, 4

# new address = old address + offset
add     $t9, $t9, $t5

########################
# branch cases

# if (opcode = 1):
#   goto opcode_1
# else:
#   compare opcode and goto

li      $t0, 1  # t0 <- 1
beq     $t8, $t0, _case_opcode_1

li      $t0, 4
beq     $t8, $t0, _case_beq #beq opcode==4

addi    $t0, $t0, 1 # now $t0 = 5
beq     $t8, $t0, _case_bne #bne opcode==5

addi    $t0, $t0, 1 # now $t0 = 6
beq     $t8, $t0, _case_blez 

addi    $t0, $t0, 1
beq     $t8, $t0, _case_bgtz

_exit:
    jr  $ra     # return

_case_opcode_1:
    # compare rt to find which instruction:
    # rt is stored by $t6
    li      $t0, 1
    beq     $t6, $t0, _case_bgez

    li      $t0, 17
    beq     $t6, $t0, _case_bgezal

    li      $t0, 0
    beq     $t6, $zero, _case_bltz

    li      $t0, 16
    beq     $t6, $t0, _case_bltzal

    # if rt is not in (1, 17, 0, 16)
    # then it is not branch instruction
    # just exit
    j       _exit

# if beq or bne, set $t5 to 1 (need print rt)
# else, set $t5 to 0 (print immediate after rs)

_case_beq:
	li      $t5, 1	# set flag

    la      $a0, str_beq
    li      $v0, 4
    syscall
    # printed beq
    j       _after_case

_case_bne:
	li      $t5, 1	# set flag
    la      $a0, str_bne
    li      $v0, 4
    syscall
    # printed bne
    j       _after_case

_case_blez:
	li      $t5, 0
    la      $a0, str_blez
    li      $v0, 4
    syscall
    # printed blez
    j       _after_case

_case_bgtz:
	li      $t5, 0
    la      $a0, str_bgtz
    li      $v0, 4
    syscall
    # printed bgtz
    j       _after_case

_case_bgez:
	li      $t5, 0
    la      $a0, str_bgez
    li      $v0, 4
    syscall
    # printed bgez
    j       _after_case

_case_bgezal:
	li      $t5, 0
    la      $a0, str_bgezal
    li      $v0, 4
    syscall
    # printed bgezal
    j       _after_case

_case_bltz:
	li      $t5, 0
    la      $a0, str_bltz
    li      $v0, 4
    syscall
    # printed bltz
    j       _after_case

_case_bltzal:
	li      $t5, 0
    la      $a0, str_bltzal
    li      $v0, 4
    syscall
    # printed bltzal

_after_case:
    # after print instruction name
    # print space, '$', <rs>, ','
    la      $a0, str_space
    li      $v0, 4
    syscall
    
    la      $a0, str_dollar
    li      $v0, 4
    syscall
    # rs in stored at $t7
    # addi    $a0, $t7, 0
    move    $a0, $t7
    li      $v0, 1
    syscall

    la      $a0, str_comma
    li      $v0, 4
    syscall

	# now we have "<name> $<rs>,"
	# if $t5 == 0, goto _print_immediate
	# 	else:	goto _print_rt
	beqz    $t5, _print_immediate
# _print_rt:
	la      $a0, str_space
    li      $v0, 4
    syscall
    
    la      $a0, str_dollar
    li      $v0, 4
    syscall
    # rt in stored at $t6
    # addi    $a0, $t6, 0
    move    $a0, $t6
    li      $v0, 1
    syscall

    la      $a0, str_comma
    li      $v0, 4
    syscall
_print_immediate:
	
	
	j       _exit