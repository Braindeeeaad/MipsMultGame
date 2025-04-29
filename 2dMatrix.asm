    #	CS2340 Lecture 1.  Mars demo of syscall
    #
    #	Author: Indrajith Thyagaraja
    #	Date: 03-12-2025
    #	Location: UTD
    #
.include     "SysCalls.asm"

.data


# Global symbol declarations
#.globl matrixpointer
#matrixpointer:      .space      144
    
    # "1 2 3 4 5 6 7 8 9 10 12 14 15 16 18 20 21 24 25 27 28 30 32 35 36 40 42 45 48 49 54 56 63 64 72 81"
.globl matrix_data
matrix_data:        .asciiz     "1 2 3 4 5 6 7 8 9 10 12 14 15 16 18 20 21 24 25 27 28 30 32 35 36 40 42 45 48 49 54 56 63 64 72 81"
.globl newline
newline:            .asciiz     "\n"
.globl space
space:              .asciiz     " "
.globl address_label
address_label:      .asciiz     "Address: 0x"
.globl align_error_msg
align_error_msg:    .asciiz     "Error: Memory alignment failure!\n"
.globl result_msg
result_msg:         .asciiz     "Found winning condition: "
.globl value_msg
value_msg:          .asciiz     "\nWinning value: "
.globl indices_msg
indices_msg:        .asciiz     "Converting indices ("
.globl comma
comma:              .asciiz     ", "
.globl closing_paren
closing_paren:      .asciiz     ") to address...\n"

.text
    #Arguments
    #a0 = num to search for
    #a1 = matrix_address
.globl linear_search
linear_search:
    addi    $sp,                    $sp,            -36                                                                             # Allocate stack space (9 registers × 4 bytes)
    sw      $ra,                    0($sp)                                                                                          # Save return address
    sw      $s0,                    4($sp)                                                                                          # Save $s0 (matrix address)
    sw      $s1,                    8($sp)                                                                                          # Save $s1 (i = index, starts at 1)
    sw      $s2,                    12($sp)                                                                                         # Save $s2 (6, for Divide)
    sw      $s3,                    16($sp)                                                                                         # Save $s3 (36, total elements)
    sw      $t0,                    20($sp)                                                                                         # Save $t0 (temporary)
    sw      $t1,                    24($sp)                                                                                         # Save $t1 (temporary)
    sw      $t2,                    28($sp)                                                                                         # Save $t2 (temporary)
    sw      $t3,                    32($sp)

    move    $s0,                    $a0                                                                                             # s0 = a0 = num to search for
    move    $s1,                    $a1                                                                                             # s1 = a1 = matrix_address
    li      $s2,                    36                                                                                              # s2 = 36(num to stop at)
    li      $s3,                    0

linear_loop:
    bge     $s3,                    $s2,            linear_neg                                                                      # if s3=i>=36, negatively end loop
    sll     $t0,                    $s3,            2                                                                               # t0 = i*4
    add     $t0,                    $t0,            $s1                                                                             # t0 = i*4 + matrix_address = current_address
    lw      $t1,                    0($t0)                                                                                          #dereference t0=> value at current_address
    beq     $t1,                    $s0,            linear_pos                                                                      # if
    addi    $s3,                    $s3,            1
    j       linear_loop

linear_pos:
    move    $v0,                    $t0
    j       linear_end

linear_neg:
    li      $v0,                    -1
    j       linear_end
linear_end:
    lw      $ra,                    0($sp)                                                                                          # Restore $ra
    lw      $s0,                    4($sp)                                                                                          # Restore $s0
    lw      $s1,                    8($sp)                                                                                          # Restore $s1
    lw      $s2,                    12($sp)                                                                                         # Restore $s2
    lw      $s3,                    16($sp)                                                                                         # Restore $s3
    lw      $t0,                    20($sp)                                                                                         # Restore $t0
    lw      $t1,                    24($sp)                                                                                         # Restore $t1
    lw      $t2,                    28($sp)                                                                                         # Restore $t2
    lw      $t3,                    32($sp)                                                                                         # Restore $t3
    addi    $sp,                    $sp,            36                                                                              # Deallocate stack
    jr      $ra                                                                                                                     # Return

.globl check_matrix
check_matrix:
    addi    $sp,                    $sp,            -36                                                                             # Allocate stack space (9 registers × 4 bytes)
    sw      $ra,                    0($sp)                                                                                          # Save return address
    sw      $s0,                    4($sp)                                                                                          # Save $s0 (matrix address)
    sw      $s1,                    8($sp)                                                                                          # Save $s1 (i = index, starts at 1)
    sw      $s2,                    12($sp)                                                                                         # Save $s2 (6, for Divide)
    sw      $s3,                    16($sp)                                                                                         # Save $s3 (36, total elements)
    sw      $t0,                    20($sp)                                                                                         # Save $t0 (temporary)
    sw      $t1,                    24($sp)                                                                                         # Save $t1 (temporary)
    sw      $t2,                    28($sp)                                                                                         # Save $t2 (temporary)
    sw      $t3,                    32($sp)

    move    $s0,                    $a0                                                                                             #s0 = matrix_pointer
    li      $s1,                    36                                                                                              #s1 = move 36, total num of items
    li      $s2,                    0                                                                                               #i=0
.globl check_loop 
check_loop:
    bge     $s2,                    $s1,            check_done
    sll     $s3,                    $s2,            2                                                                               #s3=i*4
    add     $s3,                    $s3,            $s0                                                                             #s3 = i*4 + matrix-address = current-address
    li      $t0,                    0                                                                                               #load t0 = 0(false)

    #south-east
    li      $a1,                    1
    li      $a0,                    1
    move    $a2,                    $s3                                                                                             #a2 = s3 = current-address
    move    $a3,                    $s0                                                                                             #a3 = s0 = matrix-pointer
    jal     check_directions
    or      $t0,                    $t0,            $v0
    bne     $t0,                    $zero,          check_done                                                                      #exit if we find any 4-contigous blocks

    #north-west
    li      $a1,                    -1
    li      $a0,                    -1
    move    $a2,                    $s3                                                                                             #a2 = s3 = current-address
    move    $a3,                    $s0                                                                                             #a3 = s0 = matrix-pointer
    jal     check_directions
    or      $t0,                    $t0,            $v0
    bne     $t0,                    $zero,          check_done                                                                      #exit if we find any 4-contigous blocks

    #south-west
    li      $a1,                    1
    li      $a0,                    -1
    move    $a2,                    $s3                                                                                             #a2 = s3 = current-address
    move    $a3,                    $s0                                                                                             #a3 = s0 = matrix-pointer
    jal     check_directions
    or      $t0,                    $t0,            $v0
    bne     $t0,                    $zero,          check_done                                                                      #exit if we find any 4-contigous blocks

    #north-east
    li      $a1,                    -1
    li      $a0,                    1
    move    $a2,                    $s3                                                                                             #a2 = s3 = current-address
    move    $a3,                    $s0                                                                                             #a3 = s0 = matrix-pointer
    jal     check_directions
    or      $t0,                    $t0,            $v0
    bne     $t0,                    $zero,          check_done                                                                      #exit if we find any 4-contigous blocks

    #north
    li      $a1,                    -1
    li      $a0,                    0
    move    $a2,                    $s3                                                                                             #a2 = s3 = current-address
    move    $a3,                    $s0                                                                                             #a3 = s0 = matrix-pointer
    jal     check_directions
    or      $t0,                    $t0,            $v0
    bne     $t0,                    $zero,          check_done                                                                      #exit if we find any 4-contigous blocks

    #south
    li      $a1,                    1
    li      $a0,                    0
    move    $a2,                    $s3                                                                                             #a2 = s3 = current-address
    move    $a3,                    $s0                                                                                             #a3 = s0 = matrix-pointer
    jal     check_directions
    or      $t0,                    $t0,            $v0
    bne     $t0,                    $zero,          check_done                                                                      #exit if we find any 4-contigous blocks

    #east
    li      $a1,                    0
    li      $a0,                    1
    move    $a2,                    $s3                                                                                             #a2 = s3 = current-address
    move    $a3,                    $s0                                                                                             #a3 = s0 = matrix-pointer
    jal     check_directions
    or      $t0,                    $t0,            $v0

    bne     $t0,                    $zero,          check_done                                                                      #exit if we find any 4-contigous blocks

    #west
    li      $a1,                    0
    li      $a0,                    -1
    move    $a2,                    $s3                                                                                             #a2 = s3 = current-address
    move    $a3,                    $s0                                                                                             #a3 = s0 = matrix-pointer
    jal     check_directions
    or      $t0,                    $t0,            $v0

    bne     $t0,                    $zero,          check_done                                                                      #exit if we find any 4-contigous blocks

    addi    $s2,                    $s2,            1                                                                               #s2++ == i++

    j       check_loop




.globl check_done
check_done:
    move    $v0,                    $t0                                                                                             #move the result of the iteration into v0
    lw      $v1,                    0($s3)                                                                                          #move which num caused contigous memory slots

    lw      $ra,                    0($sp)                                                                                          # Restore $ra
    lw      $s0,                    4($sp)                                                                                          # Restore $s0
    lw      $s1,                    8($sp)                                                                                          # Restore $s1
    lw      $s2,                    12($sp)                                                                                         # Restore $s2
    lw      $s3,                    16($sp)                                                                                         # Restore $s3
    lw      $t0,                    20($sp)                                                                                         # Restore $t0
    lw      $t1,                    24($sp)                                                                                         # Restore $t1
    lw      $t2,                    28($sp)                                                                                         # Restore $t2
    lw      $t3,                    32($sp)                                                                                         # Restore $t3
    addi    $sp,                    $sp,            36                                                                              # Deallocate stack
    jr      $ra                                                                                                                     # Return



    #Arguments
    #a0= x-direction
    #a1= y-direction
    #a2= current-memaddress
    #a3 = matrix_start_address
.globl check_directions
check_directions:
    addi    $sp,                    $sp,            -48                                                                             # Allocate stack space (9 registers × 4 bytes)
    sw      $ra,                    0($sp)                                                                                          # Save return address
    sw      $s0,                    4($sp)                                                                                          # Save $s0 (matrix address)
    sw      $s1,                    8($sp)                                                                                          # Save $s1 (i = index, starts at 1)
    sw      $s2,                    12($sp)                                                                                         # Save $s2 (6, for Divide)
    sw      $s3,                    16($sp)                                                                                         # Save $s3 (36, total elements)
    sw      $t0,                    20($sp)                                                                                         # Save $t0 (temporary)
    sw      $t1,                    24($sp)                                                                                         # Save $t1 (temporary)
    sw      $t2,                    28($sp)                                                                                         # Save $t2 (temporary)
    sw      $t3,                    32($sp)
    sw      $t4,                    36($sp)
    sw      $t5,                    40($sp)
    sw      $t6,                    44($sp)


    move    $s0,                    $a0                                                                                             #s0 = direction to move for x
    move    $s1,                    $a1                                                                                             #s1 = direction to move for y
    move    $s2,                    $a2                                                                                             #s2 = current mem-address
    move    $s3,                    $a3                                                                                             #s3 = matrix_start_address
    lw      $t4,                    0($s2)                                                                                          #t4 = word at current address
    sub     $s2,                    $s2,            $s3                                                                             #s2 = current - start
    sra     $s2,                    $s2,            2                                                                               #s2 =(current mem - start mem)/4 = index
    move    $a0,                    $s2                                                                                             #moving index value into argument for dividing
    li      $a1,                    6                                                                                               #loading 6 into divisor
    jal     Divide
    move    $t0,                    $v1                                                                                             #moving quotient into t0(i)
    move    $t1,                    $v0                                                                                             #moving reminder into t1(j)
    li      $t5,                    0                                                                                               #t5(loop counter) = 0


.globl check_direction_loop
check_direction_loop:
    ##gotta check and make sure t0 and t1 are within bounds, if it is, procede with setting boolean values
    slti    $t2,                    $t0,            6                                                                               # check if i< 6
    slti    $t3,                    $t1,            6                                                                               # check if j< 6
    and     $v0,                    $t3,            $t2                                                                             # v0 = (i<6) && (j<6)
    slt     $t2,                    $t0,            $zero                                                                           # check if (i<0)
    xori    $t2,                    $t2,            1                                                                               # t2 = !(i<0)=(i>=0)
    slt     $t3,                    $t1,            $zero                                                                           #check if (j<0)
    xori    $t3,                    $t3,            1                                                                               #t3 = !(j<0)=(j>=0)
    and     $v1,                    $t3,            $t2                                                                             # v1 = (i>=0) && (j>=0)
    and     $v0,                    $v1,            $v0                                                                             #v0 = v0 && v1


    beq     $v0,                    $zero,          check_direction_end                                                             #ends loop if indicies get out of position


    move    $a0,                    $t0                                                                                             #a0 = i
    move    $a1,                    $t1                                                                                             #a1 = j
    move    $a2,                    $s3                                                                                             #a2 = matrix_address
    jal     pos_to_address
    move    $t7,                    $v0

    lw      $v0,                    0($v0)                                                                                          #dereference address of current num
    bne     $v0,                    $t4,            check_direction_end                                                             #end loop if current iterable num is not equal to target num

    li      $v1,                    4                                                                                               #ends the loop if t5>=4
    bge     $t5,                    $v1,            check_direction_end
    addi    $t5,                    $t5,            1                                                                               #t5(loop-counter)++
    add     $t0,                    $t0,            $s1                                                                             #t0 = i + y-direction
    add     $t1,                    $t1,            $s0                                                                             #t1 = j + x-direction
    move    $a0,                    $t7


    move    $a0,                    $t7
    #jal print_from_address
    j       check_direction_loop

.globl check_direction_end
check_direction_end:
    jal     print_newline
    slti    $v0,                    $t5,            4                                                                               # v0 = (t5<4)-> need to return t5>=4
    xori    $v0,                    $v0,            1                                                                               # v0 = !v0 = !(t5<4) = t5>=4
    lw      $ra,                    0($sp)                                                                                          # Save return address
    lw      $s0,                    4($sp)                                                                                          # Save $s0 (matrix address)
    lw      $s1,                    8($sp)                                                                                          # Save $s1 (i = index, starts at 1)
    lw      $s2,                    12($sp)                                                                                         # Save $s2 (6, for Divide)
    lw      $s3,                    16($sp)                                                                                         # Save $s3 (36, total elements)
    lw      $t0,                    20($sp)                                                                                         # Save $t0 (temporary)
    lw      $t1,                    24($sp)                                                                                         # Save $t1 (temporary)
    lw      $t2,                    28($sp)                                                                                         # Save $t2 (temporary)
    lw      $t3,                    32($sp)
    lw      $t4,                    36($sp)
    lw      $t5,                    40($sp)
    lw      $t6,                    44($sp)
    addi    $sp,                    $sp,            48                                                                              # Allocate stack space (9 registers × 4 bytes)
    jr      $ra




    #Take a buffer of size 144 bits from memory, take that info and write to me
    #Esenitally have one init method, which initalizes that empty buffer with values form the inital string data
    #then have a method that returns memory addresses by doing a linear search given cell value
    #Have a print method that segments properly and prints
.globl init_matrix
init_matrix:
    addi    $sp,                    $sp,            -28                                                                             # Allocate stack space
    sw      $ra,                    0($sp)                                                                                          # Save return address
    sw      $s0,                    4($sp)                                                                                          # Save preserved register $s0
    sw      $s1,                    8($sp)                                                                                          # Save preserved register $s1
    sw      $t0,                    12($sp)
    sw      $t1,                    16($sp)
    sw      $t2,                    20($sp)
    sw      $t3,                    24($sp)

    move    $s0,                    $a0                                                                                             #s0 = matrix_pointer
    li      $s1,                    36                                                                                              #s1 = move 36, total num of items
    li      $t0,                    0                                                                                               #i=0
    la      $t2,                    matrix_data

.globl init_loop
init_loop:
    bge     $t0,                    $s1,            init_matrix_done                                                                #if i>=36, end loop
    sll     $t1,                    $t0,            2                                                                               #t1  = i*4
    add     $t1,                    $t1,            $s0                                                                             #t1 = i*4+matrix_address
    move    $a0,                    $t2                                                                                             #a0 = current string address
    jal     atoi                                                                                                                    #transfers control to atoi
    move    $t3,                    $v0                                                                                             #moves v0(digit) to t3s
    move    $t2,                    $v1                                                                                             #t2 = next string digit address
    sw      $t3,                    0($t1)                                                                                          #array[i*4+matrix_address] = digit
    addi    $t0,                    $t0,            1                                                                               #i++
    j       init_loop
.globl init_matrix_done
init_matrix_done:
    lw      $ra,                    0($sp)                                                                                          # load return address
    lw      $s0,                    4($sp)                                                                                          # restore preserved register $s0
    lw      $s1,                    8($sp)                                                                                          # restore preserved register $s1
    lw      $t0,                    12($sp)
    lw      $t1,                    16($sp)
    lw      $t2,                    20($sp)
    lw      $t3,                    24($sp)
    addi    $sp,                    $sp,            28                                                                              # re-provide stack space
    jr      $ra                                                                                                                     # return to caller






    # String to integer function (atoi)
    # $a0: string pointer
    # Returns:
    # $v0: integer value
    # $v1: new string pointer (after number)
.globl atoi
atoi:
    addi    $sp,                    $sp,            -20                                                                             # Allocate stack space
    sw      $ra,                    0($sp)                                                                                          # Save return address
    sw      $s0,                    4($sp)                                                                                          # Save preserved register $s0
    sw      $s1,                    8($sp)                                                                                          # Save preserved register $s1
    sw      $t0,                    12($sp)                                                                                         # Save temporary register $t0
    sw      $t1,                    16($sp)

    move    $s0,                    $a0                                                                                             # String pointer
    li      $v0,                    0                                                                                               # Initialize result
    li      $t1,                    10                                                                                              # Base 10

.globl atoi_loop
atoi_loop:
    lb      $t0,                    0($s0)                                                                                          # Load character
    beq     $t0,                    0,              atoi_exit                                                                       # Null terminator → exit
    beq     $t0,                    10,             atoi_exit                                                                       # Newline → exit
    beq     $t0,                    32,             atoi_skip_ws                                                                    # Space → skip whitespace

    # Convert digit (only if 0-9)
    blt     $t0,                    48,             atoi_invalid                                                                    # Below '0'
    bgt     $t0,                    57,             atoi_invalid                                                                    # Above '9'

    addi    $t0,                    $t0,            -48                                                                             # Convert to digit
    mul     $v0,                    $v0,            $t1                                                                             # result *= 10
    add     $v0,                    $v0,            $t0                                                                             # result += digit

    addi    $s0,                    $s0,            1                                                                               # Next char
    j       atoi_loop
.globl atoi_skip_ws
atoi_skip_ws:
    addi    $s0,                    $s0,            1                                                                               # Skip space
    lb      $t0,                    0($s0)                                                                                          # Load next char
    beq     $t0,                    32,             atoi_skip_ws                                                                    # If space, keep skipping
    j       atoi_exit                                                                                                               # Otherwise exit
.globl atoi_invalid
atoi_invalid:
    # Handle invalid digit (optional)
    li      $v0,                    -1                                                                                              # Return error code
    j       atoi_exit
.globl atoi_exit
atoi_exit:
    move    $v1,                    $s0                                                                                             # Return new pointer
    lw      $ra,                    0($sp)                                                                                          # Restore return address
    lw      $s0,                    4($sp)                                                                                          # Restore $s0
    lw      $s1,                    8($sp)                                                                                          # Restore $s1
    lw      $t0,                    12($sp)                                                                                         # Restore $t0
    lw      $t1,                    16($sp)
    addi    $sp,                    $sp,            20                                                                              # Deallocate stack
    jr      $ra                                                                                                                     # Return







.globl print_matrix
print_matrix:
    addi    $sp,                    $sp,            -36                                                                             # Allocate stack space (9 registers × 4 bytes)
    sw      $ra,                    0($sp)                                                                                          # Save return address
    sw      $s0,                    4($sp)                                                                                          # Save $s0 (matrix address)
    sw      $s1,                    8($sp)                                                                                          # Save $s1 (i = index, starts at 1)
    sw      $s2,                    12($sp)                                                                                         # Save $s2 (6, for Divide)
    sw      $s3,                    16($sp)                                                                                         # Save $s3 (36, total elements)
    sw      $t0,                    20($sp)                                                                                         # Save $t0 (temporary)
    sw      $t1,                    24($sp)                                                                                         # Save $t1 (temporary)
    sw      $t2,                    28($sp)                                                                                         # Save $t2 (temporary)
    sw      $t3,                    32($sp)                                                                                         # Save $t3 (temporary)


    move    $s0,                    $a0                                                                                             #s0 = matrix_adress
    jal     print_from_address                                                                                                      #preemptively print the first elment
    li      $s1,                    1                                                                                               # i = 1
    li      $s2,                    6                                                                                               #s2 = 6(for checking purposes
    li      $s3,                    36                                                                                              #s3 = 36(total num of items)
    j       print_row_loop
.globl print_row_loop
print_row_loop:
    bge     $s1,                    $s3,            print_matrix_done                                                               #if i>=36 end the loop
    j       print_col_loop

.globl print_col_loop
print_col_loop:
    move    $a0,                    $s1                                                                                             #load index into argument for Divide
    move    $a1,                    $s2                                                                                             #load 6 as divisor
    jal     Divide
    beq     $v0,                    $zero,          print_col_done


    sll     $a0,                    $s1,            2                                                                               #a0 = i*4
    add     $a0,                    $a0,            $s0                                                                             #a0 = i*4 + matrix_address
    jal     print_from_address                                                                                                      #print current address
    addi    $s1,                    $s1,            1                                                                               #i++
    j       print_col_loop

.globl print_col_done
print_col_done:
    li      $a0,                    10                                                                                              #loading asci newline character
    li      $v0,                    SysPrintChar                                                                                    #printing newline
    syscall #
    beq     $s1,                    $s3,            print_matrix_done                                                               #extra check to make sure loop prints properly
    sll     $a0,                    $s1,            2                                                                               #a0 = i*4
    add     $a0,                    $a0,            $s0                                                                             #a0 = i*4 + matrix_address
    jal     print_from_address                                                                                                      #print current address
    addi    $s1,                    $s1,            1                                                                               #i++
    j       print_row_loop
.globl print_matrix_done
print_matrix_done:
    lw      $ra,                    0($sp)                                                                                          # Restore $ra
    lw      $s0,                    4($sp)                                                                                          # Restore $s0
    lw      $s1,                    8($sp)                                                                                          # Restore $s1
    lw      $s2,                    12($sp)                                                                                         # Restore $s2
    lw      $s3,                    16($sp)                                                                                         # Restore $s3
    lw      $t0,                    20($sp)                                                                                         # Restore $t0
    lw      $t1,                    24($sp)                                                                                         # Restore $t1
    lw      $t2,                    28($sp)                                                                                         # Restore $t2
    lw      $t3,                    32($sp)                                                                                         # Restore $t3
    addi    $sp,                    $sp,            36                                                                              # Deallocate stack
    jr      $ra                                                                                                                     # Return




.globl print_newline
print_newline:
    addi    $sp,                    $sp,            -8                                                                              # Allocate space on stack
    sw      $ra,                    0($sp)                                                                                          # Store return address
    sw      $v0,                    4($sp)

    li      $v0,                    11                                                                                              # System call for print character
    li      $a0,                    10                                                                                              # ASCII code for newline (10)
    syscall

    lw      $ra,                    0($sp)                                                                                          # Restore return address
    lw      $v0,                    4($sp)
    addi    $sp,                    $sp,            8                                                                               # Restore stack pointer
    jr      $ra                                                                                                                     # Return to caller
.globl Divide
Divide:
    div     $a0,                    $a1                                                                                             # Divide $a0 by $a1 (LO = quotient, HI = remainder)
    mfhi    $v0                                                                                                                     # Move remainder (HI) to $v0
    mflo    $v1                                                                                                                     # Move quotient to
    jr      $ra                                                                                                                     # Return remainder in $v0
    #
    #arguments
    #a0=i
    #a1=j
    #a2=matrix_address
    #returns
    #v0=matrix_position_from address
.globl pos_to_address
pos_to_address:
    addi    $sp,                    $sp,            -16                                                                             # Allocate stack space (extra word for printing)
    sw      $ra,                    0($sp)                                                                                          # Save return address
    sw      $s0,                    4($sp)                                                                                          # Save $s0
    sw      $s1,                    8($sp)                                                                                          # Save $s1
    sw      $t0,                    12($sp)                                                                                         # Save $t0

    move    $s0,                    $a0                                                                                             # s0 = i
    move    $s1,                    $a1
    # Print indices message
    li      $v0,                    4
    la      $a0,                    indices_msg
    syscall

    # Print i value
    move    $a0,                    $s0                                                                                             # Original i is in $a1 (MIPS calling convention)
    li      $v0,                    1
    syscall

    # Print comma separator
    li      $v0,                    4
    la      $a0,                    comma
    syscall

    # Print j value
    move    $a0,                    $s1                                                                                             # Original j is in $a2
    li      $v0,                    1
    syscall

    # Print closing parenthesis
    li      $v0,                    4
    la      $a0,                    closing_paren
    syscall


    # Original address calculation
    li      $t0,                    6
    mul     $s0,                    $s0,            $t0                                                                             # s0 = 6*i
    add     $v0,                    $s0,            $s1                                                                             # v0 = 6*i + j
    sll     $v0,                    $v0,            2                                                                               # $v0 = (6 * i + j) * 4
    add     $v0,                    $v0,            $a2                                                                             # $v0 = matrix_address + byte offset
    move    $t7,                    $v0
    move    $a0,                    $v0
    li      $v0,                    SysPrintIntHex
    syscall
    move    $v0,                    $t7
    # Restore registers
    lw      $ra,                    0($sp)
    lw      $s0,                    4($sp)
    lw      $s1,                    8($sp)
    lw      $t0,                    12($sp)
    addi    $sp,                    $sp,            16
    jr      $ra

.globl print_from_address
print_from_address:
    addi    $sp,                    $sp,            -4                                                                              # Allocate stack space
    sw      $ra,                    0($sp)


    lw      $a0,                    0($a0)
    li      $v0,                    SysPrintInt
    syscall
    li      $a0,                    32                                                                                              #load space ascii character
    li      $v0,                    SysPrintChar                                                                                    #prints space after printing the int
    syscall

    lw      $ra,                    0($sp)
    addi    $sp,                    $sp,            4


    jr      $ra
.globl print_address
print_address:
    addi    $sp,                    $sp,            -4                                                                              # Allocate stack space
    sw      $ra,                    0($sp)                                                                                          # Save return address

    # Print the address label
    li      $v0,                    4                                                                                               # syscall for print_string
    la      $a0,                    address_label
    syscall

    # Print the actual address value
    move    $a0,                    $a0                                                                                             # Move input address to $a0 (redundant but clear)
    li      $v0,                    34                                                                                              # syscall for print_hex
    syscall

    # Print newline
    li      $v0,                    11                                                                                              # syscall for print_char
    li      $a0,                    10                                                                                              # ASCII newline
    syscall

    lw      $ra,                    0($sp)                                                                                          # Restore return address
    addi    $sp,                    $sp,            4                                                                               # Deallocate stack space
    jr      $ra                                                                                                                     # Return


