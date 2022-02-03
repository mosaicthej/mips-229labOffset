.data
str_bgez: 	.asciiz "bgez "
str_bgezal: .asciiz "bgezal "
str_bltz:	.asciiz "bltz "
str_bltzal:	.asciiz "bltzal "
str_beq:	.asciiz "beq "
str_bne:	.asciiz "bne "
str_blez:	.asciiz "blez "
str_bgtz:	.asciiz "bgtz "
str_comma:  .asciiz ", "
str_dollar:	.asciiz "$"
str_0x:		.asciiz "0x"


.text

disassembleBranch:
    # @arg:
    #   $a0: address of this branch instruction.
    # @out:
    #   if instruction is not branch: no output.
    #   if instruction a branch, print instruction to screen
    lw      $t7, 0($a0)     # load instruction in $a0 to $t7
    # now dissect $t7 to fields: opcode, s-reg, t-reg, immediate
    # needs 4 s registers to save them. 
	# also need registers for the rt-flag and loop counter as we need to 
	# step into the syscall function, which may overwrite t-registers
	
	# Preserve registers:
    addi	$sp, $sp, -24	# allocate memory.
    sw      $s0, 0($sp) 	# $s0 in 1st
    sw      $s1, 4($sp) 	# $s1 in 2nd   
    sw 		$s2, 8($sp) 	# $s2 in 3rd
	sw      $s3, 12($sp) 	# $s3 in 4th
	sw      $s4, 16($sp)	# $s4 in 5th
	sw		$s5, 20($sp)	# $s5 in 6th


    srl		$s0, $t7, 26		# $s0 now holds the opcode
    
	sll     $s1, $t7, 6		
	srl		$s1, $s1, 27		# $s1 now holds the s-reg

	sll		$s2, $t7, 11
	sll		$s2, $s2, 27		# $s2 now holds the t-reg

	sll		$s3, $t7, 16
	srl		$s3, $s3, 14		# $s3 now holds the immediate << 2
	# instruction's address is stored at $a0 (argument), 
	# also, need to add 4 to address because we are using 
	# the address for instruction not PC
	add		$s3, $s3, $a0		# $s3 = $s3 + instructionAddr.
	addi	$s3, $s3, 4			# $s3 = $s3 + 4
	# now $s3 holds the address of the branched instruction


	addi    $t0, $zero, 1		# $t0 = 1
	beq		$t0, $s0, _opc1		# if opcode == 1, goto _opc1
	
	addi    $t0, $zero, 4		# $t0 = 4
	beq		$t0, $s0, _beq		# if opcode == 4, goto _opc4, beq
	 
	addi    $t0, $zero, 5		# $t0 = 5
	beq		$t0, $s0, _bne		# if opcode == 5, goto _opc5, bne

	addi    $t0, $zero, 6		# $t0 = 6
	beq		$t0, $s0, _blez		# if opcode == 6, goto _opc6, blez
	
	addi    $t0, $zero, 7		# $t0 = 7
	beq		$t0, $s0, _bgtz		# if opcode == 7, goto _opc7, bgtz

# naturally flow to exit point
_done:
    # when program terminates, 
	lw      $s5, 20($sp)		# restore $s5
	lw		$s4, 16	($sp)		# restore $s4
	lw		$s3, 12($sp)		# restore $s3	
	lw 		$s2, 8($sp)			# Restore $s2.
  	lw 	  	$s1, 4($sp)         # Restore $s1.
  	lw    	$s0, 0($sp) 		# Restore $s0.
  	addi  	$sp, $sp, 24		# Deallocate three slots from stack.

	# return to calling routine
    jr		$ra					# jump to $ra
    
_opc1:
	# branches according to the t-reg value hold by $s2
	# 1 = 00001
	addi    $t0, $zero, 1		# $t0 = 1
	beq		$t0, $s2, _bgez		# if t-reg == 1, goto _bgez

	# 17 = 10001
	addi    $t0, $zero, 17		# $t0 = 17
	beq		$t0, $s2, _bgezal	# if t-reg == 17, goto _bgezal

	# 0 = 00000
	addi    $t0, $zero, 0		# $t0 = 0
	beq		$t0, $s2, _bltz	# if t-reg == 0, goto _bltz

	# 16 = 10000
	addi    $t0, $zero, 16		# $t0 = 16
	beq		$t0, $s2, _bltzal	# if t-reg == 16, goto _bltzal


# branches to load instruction text
# also determines if t-reg are included or not (by using flag in $s4)

_bgez: # no t-reg
	addi    $s4, $zero, 0
	la      $a0, str_bgez	# load instruction text
	j       _toPrint

_bgezal: # no t-reg
	addi    $s4, $zero, 0
	la      $a0, str_bgezal	# load instruction text
	j       _toPrint

_bltz: # no t-reg
	addi 	$s4, $zero, 0
	la      $a0, str_bltz	# load instruction text
	j       _toPrint

_bltzal: # no t-reg
	addi	$s4, $zero, 0
	la      $a0, str_bltzal	# load instruction text
	j       _toPrint
	
_beq: # has t-reg
	addi    $s4, $zero, 1
	la		$a0, str_beq	# load instruction text
	j       _toPrint

_bne: # has t-reg
	addi    $s4, $zero, 1
	la      $a0, str_bne	# load instruction text
	j       _toPrint

_blez: # no t-reg
	addi	$s4, $zero, 0
	la      $a0, str_blez	# load instruction text
	j       _toPrint
	
_bgtz: # no t-reg
	addi	$s4, $zero, 0
	la      $a0, str_bgtz	# load instruction text

_toPrint: # procedure to print
	# print instruction, (which is already saved in $a0)
	li      $v0, 4		# print instruction
	syscall

	# print $
	la		$a0, str_dollar	# load $
	li		$v0, 4		# print $
	syscall

	# print s-reg number, which is in $s1
	addi	$a0, $s1, 0
	li      $v0, 1		# print int
	syscall				
	la		$a0, str_comma
	li      $v0, 4
	syscall

	# check the flag ($s4) to see if need to print t-reg
	beqz    $s4, _prtImmd # if flag is 0, proceed to immediate printing
	# else, print t-reg first, which is in $s2
	# print $$
	la		$a0, str_dollar	# load $
	li		$v0, 4		# print $
	syscall
	addi	$a0, $s2, 0
	li      $v0, 1		# print int
	syscall				
	la		$a0, str_comma
	li      $v0, 4
	syscall

	
_prtImmd:
	# print hex prefix (0x) first
	la		$a0, str_0x
	li      $v0, 4
	syscall

	# logic in C as following:

	# i = 8
	# while (i>0) {
	#	load_ith_digit()
	# 	if (is_digit){
	# 		print_digit();}
	# 	else {
	# 		print_letter();
	# 	}
	# 	i--;
	# }


	addi    $s5, $zero, 8	# $s5 as counter to loop
	addi	$t5, $zero, 10	# set the numeric-alphbetic threshold
	_prtDigLoop:
		# exit the loop if counter < 0:
		blez	$s5, _done

		srl		$t6, $s3, 28 	# putting top 4-bit (1-hex-char) to $t6
		sll		$s3, $s3, 4		# move the header to next hex
		# compare against the threshold to check if goto print letter or digit
		blt		$t6, $t5, _setNum
		_setABC:
			# print the value in $t6 (>10) as letter
			# change it from numeric value to 
			# 	the corresponding ascii char value.
			# add 55 from 10 -> 'A', 11 -> 'B', etc...
			addi	$a0, $t6, 55
			j		_prtChar	# past the if-clause
		_setNum:
			# print the value in $t6 as digit(as appeared)
			# add 48 from 0->'0', 1->'1', ...
			addi	$a0, $t6, 48
		_prtChar:
			# with $a0 store the char value of what to be printed
			li		$v0, 11			# print_char mode
			syscall 

		_prtDigLoopEnds:
			# the hex 4-bit has printed.
			# decrease the counter, and go to head of the loop
			addi	$s5, $s5, -1
			j		_prtDigLoop