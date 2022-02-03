.data


.text

disassembleBranch:
    # @arg:
    #   $a0: address of this branch instruction.
    # @out:
    #   if instruction is not branch: no output.
    #   if instruction a branch, print instruction to screen
    lw      $t7, 0($a0)     # load instruction in $a0 to $t7
    # now dissect $t7 to fields: opcode, s-reg, t-reg, immediate
    # needs 4 s registers to save them. Preserve registers:
    addi	$sp, $sp, -16	# allocate memory.
    sw      $s0, 0($sp) 	# $s0 in 1st
    sw      $s1, 4($sp) 	# $s1 in 2nd   
    sw 		$s2, 8($sp) 	# $s2 in 3rd
	sw      $s3, 12($sp) 	# $s3 in 4th


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
	lw		$s3, 12($sp)			
	lw 		$s2, 8($sp)			# Restore $s2.
  	lw 	  	$s1, 4($sp)         # Restore $s1.
  	lw    	$s0, 0($sp) 		# Restore $s0.
  	addi  	$sp, $sp, 16 		# Deallocate three slots from stack.

	# return to calling routine
    jr		$ra					# jump to $ra
    
_opc1:
	# branches according to the t-reg value hold by $s2
	# 1 = 00001
	addi    $t0, $zero, 1		# $t0 = 1
	beq		$t0, $s0, _bgez		# if t-reg == 1, goto _bgez

	# 17 = 10001
	addi    $t0, $zero, 17		# $t0 = 17
	beq		$t0, $s0, _begzal	# if t-reg == 17, goto _bgezal

	# 0 = 00000
	addi    $t0, $zero, 0		# $t0 = 0
	beq		$t0, $s0, _begzal	# if t-reg == 0, goto _bltz

	# 16 = 10000
	addi    $t0, $zero, 16		# $t0 = 16
	beq		$t0, $s0, _begzal	# if t-reg == 16, goto _bltzal

	
