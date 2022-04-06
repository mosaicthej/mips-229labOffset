
.data
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
# new address at $t9
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


_case_beq:
    la      $a0, str_beq
    li      $v0, 4
    syscall
    # printed beq
    j       _after_case
_case_bne:
    la      $a0, str_bne
    li      $v0, 4
    syscall
    # printed bne
    j       _after_case

_case_blez:
    la      $a0, str_blez
    li      $v0, 4
    syscall
    # printed blez
    j       _after_case

_case_bgtz:
    la      $a0, str_bgtz
    li      $v0, 4
    syscall
    # printed bgtz
    j       _after_case

_case_bgez:
    la      $a0, str_bgez
    li      $v0, 4
    syscall
    # printed bgez
    j       _after_case

_case_bgezal:
    la      $a0, str_bgezal
    li      $v0, 4
    syscall
    # printed bgezal
    j       _after_case

_case_bltz:
    la      $a0, str_bltz
    li      $v0, 4
    syscall
    # printed bltz
    j       _after_case

_case_bltzal:
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

_print_immediate:
    li      $t0, 8
    li      $t1, 10

    _loop_head:
    beqz    $t0, _exit  # while t0 != 0
    srl     $t5, $t9, 28
    # now $t5 has the top 4 bits of the new address
    blt     $t5, $t1, _set_num
    # if not branched, $t5 >= 10, do set_letter
        addi    $t5, $t5, 87 
        j       _print_hex_char
        _set_num:
        addi    $t5, $t5, 48

    _print_hex_char:
    move    $a0, $t5
    li      $v0, 11
    syscall
     
    sll     $t9, $t9, 4
    
    addi    $t0, $t0, -1    # $t0--;
    j       _loop_head

