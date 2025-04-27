    #	CS2340 Lecture 1.  Mars demo of syscall
    #
    #	Author: Indrajith Thyagaraja
    #	Date: 03-12-2025
    #	Location: UTD
    #

                    .include    "SysCalls.asm"                                                                                          # include this file in all programs
.data
matrixpointer:      .space      144
matrix_data:        .asciiz     "1 2 3 4 5 6 7 8 9 10 12 14 15 16 18 20 21 24 25 27 28 30 32 35 36 40 42 45 48 49 54 56 63 64 72 81"
newline:            .asciiz     "\n"
space:              .asciiz     " "
address_label:      .asciiz     "Address: 0x"
align_error_msg:    .asciiz     "Error: Memory alignment failure!\n"



.text
    la      $a0,                    matrixpointer                                                                                       # Load matrix pointer address
    jal     init_matrix                                                                                                       # Initialize with our data

    la      $a0,                    matrixpointer
    jal     print_matrix

    li      $v0,                    10                                                                                                  # Exit
    syscall


    #Take a buffer of size 144 bits from memory, take that info and write to me
    #Esenitally have one init method, which initalizes that empty buffer with values form the inital string data
    #then have a method that returns memory addresses by doing a linear search given cell value
    #Have a print method that segments properly and prints

init_matrix:
    addi    $sp,                    $sp,            -28                                                                                 # Allocate stack space
    sw      $ra,                    0($sp)                                                                                              # Save return address
    sw      $s0,                    4($sp)                                                                                              # Save preserved register $s0
    sw      $s1,                    8($sp)                                                                                              # Save preserved register $s1
    sw      $t0,                    12($sp)
    sw      $t1,                    16($sp)
    sw      $t2,                    20($sp)
    sw      $t3,                    24($sp)

    move    $s0,                    $a0                                                                                                 #s0 = matrix_pointer
    li      $s1,                    36                                                                                                  #s1 = move 36, total num of items
    li      $t0,                    0                                                                                                   #i=0
    la      $t2,                    matrix_data

init_loop:
    bge     $t0,                    $s1,            init_matrix_done                                                                    #if i>=36, end loop
    sll     $t1,                    $t0,            2                                                                                   #t1  = i*4
    add     $t1,                    $t1,            $s0                                                                                 #t1 = i*4+matrix_address
    move    $a0,                    $t2                                                                                                 #a0 = current string address
    jal     atoi                                                                                                                        #transfers control to atoi
    move    $t3,                    $v0                                                                                                 #moves v0(digit) to t3s
    move    $t2,                    $v1                                                                                                 #t2 = next string digit address
    sw      $t3,                    0($t1)                                                                                               #array[i*4+matrix_address] = digit
    addi    $t0,                    $t0,            1                                                                                   #i++
    j       init_loop

init_matrix_done:
    lw      $ra,                    0($sp)                                                                                              # load return address
    lw      $s0,                    4($sp)                                                                                              # restore preserved register $s0
    lw      $s1,                    8($sp)                                                                                              # restore preserved register $s1
    lw      $t0,                    12($sp)
    lw      $t1,                    16($sp)
    lw      $t2,                    20($sp)
    lw      $t3,                    24($sp)
    addi    $sp,                    $sp,            28                                                                                  # re-provide stack space
    jr      $ra                                                                                                                         # retrurn to caller

    # String to integer function (atoi)
    # $a0: string pointer
    # Returns:
    # $v0: integer value
    # $v1: new string pointer (after number)
atoi:
    addi    $sp,                    $sp,            -20                                                                                 # Allocate stack space
    sw      $ra,                    0($sp)                                                                                              # Save return address
    sw      $s0,                    4($sp)                                                                                              # Save preserved register $s0
    sw      $s1,                    8($sp)                                                                                              # Save preserved register $s1
    sw      $t0,                    12($sp)                                                                                             # Save temporary register $t0
    sw      $t1,                    16($sp)

    move    $s0,                    $a0                                                                                                 # String pointer
    li      $v0,                    0                                                                                                   # Initialize result
    li      $t1,                    10                                                                                                  # Base 10

atoi_loop:
    lb      $t0,                    0($s0)                                                                                              # Load character
    beq     $t0,                    0,              atoi_exit                                                                           # Null terminator → exit
    beq     $t0,                    10,             atoi_exit                                                                           # Newline → exit
    beq     $t0,                    32,             atoi_skip_ws                                                                        # Space → skip whitespace

    # Convert digit (only if 0-9)
    blt     $t0,                    48,             atoi_invalid                                                                        # Below '0'
    bgt     $t0,                    57,             atoi_invalid                                                                        # Above '9'

    addi    $t0,                    $t0,            -48                                                                                 # Convert to digit
    mul     $v0,                    $v0,            $t1                                                                                 # result *= 10
    add     $v0,                    $v0,            $t0                                                                                 # result += digit

    addi    $s0,                    $s0,            1                                                                                   # Next char
    j       atoi_loop

atoi_skip_ws:
    addi    $s0,                    $s0,            1                                                                                   # Skip space
    lb      $t0,                    0($s0)                                                                                              # Load next char
    beq     $t0,                    32,             atoi_skip_ws                                                                        # If space, keep skipping
    j       atoi_exit                                                                                                                   # Otherwise exit

atoi_invalid:
    # Handle invalid digit (optional)
    li      $v0,                    -1                                                                                                  # Return error code
    j       atoi_exit

atoi_exit:
    move    $v1,                    $s0                                                                                                 # Return new pointer
    lw      $ra,                    0($sp)                                                                                              # Restore return address
    lw      $s0,                    4($sp)                                                                                              # Restore $s0
    lw      $s1,                    8($sp)                                                                                              # Restore $s1
    lw      $t0,                    12($sp)                                                                                             # Restore $t0
    lw      $t1,                    16($sp)
    addi    $sp,                    $sp,            20                                                                                  # Deallocate stack
    jr      $ra                                                                                                                         # Return

print_matrix:
    addi    $sp,                    $sp,            -36                                                                                 # Allocate stack space (9 registers × 4 bytes)
    sw      $ra,                    0($sp)                                                                                              # Save return address
    sw      $s0,                    4($sp)                                                                                              # Save $s0 (matrix address)
    sw      $s1,                    8($sp)                                                                                              # Save $s1 (i = index, starts at 1)
    sw      $s2,                    12($sp)                                                                                             # Save $s2 (6, for modulo)
    sw      $s3,                    16($sp)                                                                                             # Save $s3 (36, total elements)
    sw      $t0,                    20($sp)                                                                                             # Save $t0 (temporary)
    sw      $t1,                    24($sp)                                                                                             # Save $t1 (temporary)
    sw      $t2,                    28($sp)                                                                                             # Save $t2 (temporary)
    sw      $t3,                    32($sp)                                                                                             # Save $t3 (temporary)


    move    $s0,                    $a0                                                                                                 #s0 = matrix_adress
    jal     print_from_address                                                                                                          #preemptively print the first elment
    li      $s1,                    1                                                                                                   # i = 1
    li      $s2,                    6                                                                                                   #s2 = 6(for checking purposes
    li      $s3,                    36                                                                                                  #s3 = 36(total num of items)
    j       print_row_loop

print_row_loop:
    bge     $s1,                    $s3,            print_matrix_done                                                                   #if i>=36 end the loop
    j       print_col_loop

print_col_loop:
    move    $a0,                    $s1                                                                                                 #load index into argument for modulo
    move    $a1,                    $s2                                                                                                 #load 6 as divisor
    jal     modulo
    beq     $v0,                    $zero,          print_col_done


    sll     $a0,                    $s1,             2                                                                                   #a0 = i*4
    add     $a0,                    $a0,            $s0                                                                                 #a0 = i*4 + matrix_address
    jal     print_from_address                                                                                                          #print current address
    addi    $s1,                    $s1,            1                                                                                   #i++
    j       print_col_loop


print_col_done:
    li      $a0,                    10                                                                                                  #loading asci newline character
    li      $v0,                    SysPrintChar                                                                                        #printing newline
    syscall #
    beq $s1,    $s3, print_matrix_done                                                      #extra check to make sure loop prints properly
    sll     $a0,                    $s1,            2                                                                                   #a0 = i*4
    add     $a0,                    $a0,            $s0                                                                                 #a0 = i*4 + matrix_address
    jal     print_from_address                                                                                                          #print current address
    addi    $s1,                    $s1,            1                                                                                   #i++
    j       print_row_loop

print_matrix_done:
    lw      $ra,                    0($sp)                                                                                              # Restore $ra
    lw      $s0,                    4($sp)                                                                                              # Restore $s0
    lw      $s1,                    8($sp)                                                                                              # Restore $s1
    lw      $s2,                    12($sp)                                                                                             # Restore $s2
    lw      $s3,                    16($sp)                                                                                             # Restore $s3
    lw      $t0,                    20($sp)                                                                                             # Restore $t0
    lw      $t1,                    24($sp)                                                                                             # Restore $t1
    lw      $t2,                    28($sp)                                                                                             # Restore $t2
    lw      $t3,                    32($sp)                                                                                             # Restore $t3
    addi    $sp,                    $sp,            36                                                                                  # Deallocate stack
    jr      $ra                                                                                                                         # Return

modulo:
    div     $a0,                    $a1                                                                                                 # Divide $a0 by $a1 (LO = quotient, HI = remainder)
    mfhi    $v0                                                                                                                         # Move remainder (HI) to $v0
    jr      $ra                                                                                                                         # Return remainder in $v0
    #
    #arguments
    #a0=i
    #a1=j
    #a2=matrix_address
    #returns
    #v0=matrix_position_from address
pos_to_address:
    addi    $sp,                    $sp,            -16                                                                                 # Allocate stack space
    sw      $ra,                    0($sp)                                                                                              # Save return address
    sw      $s0,                    4($sp)                                                                                              # Save preserved register $s0
    sw      $s1,                    8($sp)                                                                                              # Save preserved register $s1
    sw      $t0,                    12($sp)                                                                                             # Save temporary register $t0

    move    $s0,                    $a0                                                                                                 # s0 = i
    move    $s1,                    $a1                                                                                                 # s1 = j
    li      $t1,                    6                                                                                                   #t1 = 6
    mul     $s0,                    $s0,            $t1                                                                                 #s0 = 6*i
    add     $v0,                    $s0,            $s1                                                                                 #v0 = 6*i + j
    sll     $v0,                    $v0,            2                                                                                   # $v0 = (6 * i + j) * 4 (byte offset)
    add     $v0,                    $v0,            $a2                                                                                 # $v0 = matrix_address + byte offset


    lw      $ra,                    0($sp)                                                                                              # Restore return address
    lw      $s0,                    4($sp)                                                                                              # Restore $s0
    lw      $s1,                    8($sp)                                                                                              # Restore $s1
    lw      $t0,                    12($sp)                                                                                             # Restore $t0
    addi    $sp,                    $sp,            16                                                                                  # Deallocate stack space
    jr      $ra                                                                                                                         # Return to caller

print_from_address:
    addi    $sp,                    $sp,            -4                                                                                  # Allocate stack space
    sw      $ra,                    0($sp)
    lw      $a0,                    0($a0)
    li      $v0,                    SysPrintInt
    syscall
    lw      $ra,                    0($sp)
    addi    $sp,                    $sp,            4
    li      $a0,                    32                                                                                                  #load space ascii character
    li      $v0,                    SysPrintChar                                                                                        #prints space after printing the int
    syscall

    jr      $ra

print_address:
    addi    $sp,                    $sp,            -4                                                                                  # Allocate stack space
    sw      $ra,                    0($sp)                                                                                              # Save return address

    # Print the address label
    li      $v0,                    4                                                                                                   # syscall for print_string
    la      $a0,                    address_label
    syscall

    # Print the actual address value
    move    $a0,                    $a0                                                                                                 # Move input address to $a0 (redundant but clear)
    li      $v0,                    34                                                                                                  # syscall for print_hex
    syscall

    # Print newline
    li      $v0,                    11                                                                                                  # syscall for print_char
    li      $a0,                    10                                                                                                  # ASCII newline
    syscall

    lw      $ra,                    0($sp)                                                                                              # Restore return address
    addi    $sp,                    $sp,            4                                                                                   # Deallocate stack space
    jr      $ra                                                                                                                         # Return
