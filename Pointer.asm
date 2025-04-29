
    #.include    "2dMatrix.asm"
                .include    "SysCalls.asm"

.data
                .globl      left_border
                .globl      right_border
left_border:    .asciiz     "| "
separator:      .asciiz     " | "
right_border:   .asciiz     " |"
newline:        .asciiz     "\n"
space:          .asciiz     " "
zero_label:     .asciiz "0:"
one_label:      .asciiz "1:"
array_label:    .asciiz "a:"
caret:          .asciiz "&"

.text
    #
    #Need to do move validation(linear-search->returns(-1, then invalid move)
    #Need an array from [1,...,9]



    #$a0 = firstpointer-address
    #$a1 = secondpointer-address
    #$a2 = firstpointer new value
    #$a3 = secondpointer new value
    #$t0 = player or compuer(-1 for comp, -2 for player)
    #$t1 = matrix_address
                .globl      move_pointers
move_pointers:
    addi    $sp,                            $sp,                                        -36                         # Allocate stack space (9 registers × 4 bytes)
    sw      $ra,                            0($sp)                                                                  # Save return address
    sw      $s0,                            4($sp)                                                                  # Save $s0 (matrix address)
    sw      $s1,                            8($sp)                                                                  # Save $s1 (i = index, starts at 1)
    sw      $s2,                            12($sp)                                                                 # Save $s2 (6, for Divide)
    sw      $s3,                            16($sp)                                                                 # Save $s3 (36, total elements)
    sw      $t0,                            20($sp)                                                                 # Save $t0 (temporary)
    sw      $t1,                            24($sp)                                                                 # Save $t1 (temporary)
    sw      $t2,                            28($sp)                                                                 # Save $t2 (temporary)
    sw      $t3,                            32($sp)

    move    $s0,                            $a0                                                                     # s0 = address of firstpointer
    move    $s1,                            $a1                                                                     # s1 = address of fsecondpointer
    move    $s2,                            $a2                                                                     # s2 =  new first-val
    move    $s3,                            $a3                                                                     # s3 =  new sec val

   
    mul     $t2,                            $s2,                                        $s3                         # t1 = i * j
    move    $a0,                            $t2                                                                     # a0 = i * j
    move    $a1,                            $t1                                                                     # a1 = matrix_address
    jal     linear_search

    # result of search(mem-address given or -1)
    blt     $v0,                            $zero                move_pointers_done
    beq     $zero,                          $zero               move_pointers_pos
move_pointers_pos:
    sw      $s2,                            0($s0)
    sw      $s3,                            0($s1)
    sw      $t0,                            0($v0)
    li      $v0,                            1
move_pointers_done:

    slt     $v0,                            $zero             $v0
    lw      $ra,                            0($sp)                                                                  # Restore $ra
    lw      $s0,                            4($sp)                                                                  # Restore $s0
    lw      $s1,                            8($sp)                                                                  # Restore $s1
    lw      $s2,                            12($sp)                                                                 # Restore $s2
    lw      $s3,                            16($sp)                                                                 # Restore $s3
    lw      $t0,                            20($sp)                                                                 # Restore $t0
    lw      $t1,                            24($sp)                                                                 # Restore $t1
    lw      $t2,                            28($sp)                                                                 # Restore $t2
    lw      $t3,                            32($sp)                                                                 # Restore $t3
    addi    $sp,                            $sp,                                        36                          # Deallocate stack
    jr      $ra                                                                                                     # Return







                .globl      init_array

    #a0 = array-address
init_array:
    addi    $sp,                            $sp,                                        -36                         # Allocate stack space (9 registers × 4 bytes)
    sw      $ra,                            0($sp)                                                                  # Save return address
    sw      $s0,                            4($sp)                                                                  # Save $s0 (matrix address)
    sw      $s1,                            8($sp)                                                                  # Save $s1 (i = index, starts at 1)
    sw      $s2,                            12($sp)                                                                 # Save $s2 (6, for Divide)
    sw      $s3,                            16($sp)                                                                 # Save $s3 (36, total elements)
    sw      $t0,                            20($sp)                                                                 # Save $t0 (temporary)
    sw      $t1,                            24($sp)                                                                 # Save $t1 (temporary)
    sw      $t2,                            28($sp)                                                                 # Save $t2 (temporary)
    sw      $t3,                            32($sp)

    li      $s0,                            0                                                                       #i = 0
    li      $s1,                            9                                                                       #limit(9)
    move    $s2,                            $a0                                                                     #s2 = array address
init_array_loop:
    bge     $s0,                            $s1,                                        init_array_done
    sll     $t0,                            $s0,                                        2                           #t0 = i*4
    add     $t0,                            $t0,                                        $s2                         #t1 = i*4 +array_address = current_address
    addi    $s0,                            $s0,                                        1                           #s0 = i + 1
    sw      $s0,                            0($t0)                                                                  # value_at(current-address) = i + 1
    j       init_array_loop

init_array_done:
    lw      $ra,                            0($sp)                                                                  # Restore $ra
    lw      $s0,                            4($sp)                                                                  # Restore $s0
    lw      $s1,                            8($sp)                                                                  # Restore $s1
    lw      $s2,                            12($sp)                                                                 # Restore $s2
    lw      $s3,                            16($sp)                                                                 # Restore $s3
    lw      $t0,                            20($sp)                                                                 # Restore $t0
    lw      $t1,                            24($sp)                                                                 # Restore $t1
    lw      $t2,                            28($sp)                                                                 # Restore $t2
    lw      $t3,                            32($sp)                                                                 # Restore $t3
    addi    $sp,                            $sp,                                        36                          # Deallocate stack
    jr      $ra                                                                                                     # Return

                .globl      print_array
    #a0 = array-address
print_array:
    addi    $sp,                            $sp,                                        -16                         # Allocate stack space
    sw      $ra,                            0($sp)                                                                  # Save return address
    sw      $s0,                            4($sp)                                                                  # Save $s0 (array address)
    sw      $s1,                            8($sp)                                                                  # Save $s1 (counter)
    sw      $t0,                            12($sp)                                                                 # Save $t0 (temporary)

    move    $s0,                            $a0                                                                     # Load array address
    li      $s1,                            0                                                                       # Initialize counter

    # Print left border
    li      $v0,                            SysPrintString
    la      $a0,                            left_border
    syscall

print_loop:
    # Calculate address
    sll     $t0,                            $s1,                                        2                           # $t0 = index * 4
    add     $t0,                            $s0,                                        $t0                         # $t0 = array + offset

    # Print element
    li      $v0,                            SysPrintInt
    lw      $a0,                            0($t0)                                                                  # Load array element
    syscall

    # Check if we're at the last element
    addi    $s1,                            $s1,                                        1                           # Increment counter
    bge     $s1,                            9,                                          print_end                   # If we've printed all elements, exit

    # Print separator
    li      $v0,                            SysPrintString
    la      $a0,                            separator
    syscall
    j       print_loop

print_end:
    # Print right border
    li      $v0,                            SysPrintString
    la      $a0,                            right_border
    syscall

    # Print newline
    li      $v0,                            SysPrintString
    la      $a0,                            newline
    syscall

    # Restore registers
    lw      $ra,                            0($sp)
    lw      $s0,                            4($sp)
    lw      $s1,                            8($sp)
    lw      $t0,                            12($sp)
    addi    $sp,                            $sp,                                        16
    jr      $ra

    #initalize two pointer, first starts at 1(or 0/-1),
    #the second pointer gets randomly appointed from 2-9
                .globl      init_pointers
    #$a0 = firstpointer
    #$a1 = secpointer

init_pointers:
    addi    $sp,                            $sp,                                        -36                         # Allocate stack space (9 registers × 4 bytes)
    sw      $ra,                            0($sp)                                                                  # Save return address
    sw      $s0,                            4($sp)                                                                  # Save $s0 (matrix address)
    sw      $s1,                            8($sp)                                                                  # Save $s1 (i = index, starts at 1)
    sw      $s2,                            12($sp)                                                                 # Save $s2 (6, for Divide)
    sw      $s3,                            16($sp)                                                                 # Save $s3 (36, total elements)
    sw      $t0,                            20($sp)                                                                 # Save $t0 (temporary)
    sw      $t1,                            24($sp)                                                                 # Save $t1 (temporary)
    sw      $t2,                            28($sp)                                                                 # Save $t2 (temporary)
    sw      $t3,                            32($sp)

    move    $s0,                            $a0                                                                     # s0 = firstpointer-address
    move    $s1,                            $a1                                                                     # s1 = secpointer-address
    li      $s2,                            1
    sw      $s2,                            0($s0)                                                                  # set value_of(firstpointer-address) = -1

    li      $a1,                            8                                                                       #Here you set $a1 to the max bound.
    li      $v0,                            SysRandIntRange                                                         #generates the random number.
    syscall
    add     $s2,                            $a0,                                        1                           #Here you add the lowest bound

    sw      $s2,                            0($s1)                                                                  # set value_of(secpointer-address) = rand(0,8) + 1 = randint from 1-8

    lw      $ra,                            0($sp)                                                                  # Restore $ra
    lw      $s0,                            4($sp)                                                                  # Restore $s0
    lw      $s1,                            8($sp)                                                                  # Restore $s1
    lw      $s2,                            12($sp)                                                                 # Restore $s2
    lw      $s3,                            16($sp)                                                                 # Restore $s3
    lw      $t0,                            20($sp)                                                                 # Restore $t0
    lw      $t1,                            24($sp)                                                                 # Restore $t1
    lw      $t2,                            28($sp)                                                                 # Restore $t2
    lw      $t3,                            32($sp)                                                                 # Restore $t3
    addi    $sp,                            $sp,                                        36                          # Deallocate stack
    jr      $ra                                                                                                     # Return




                .globl      print_pointers
    #$a0 = firstpointer
    #$a1 = secpointer
    #$a2 = array

print_pointers:
    addi    $sp,                            $sp,                                        -36                         # Allocate stack space
    sw      $ra,                            0($sp)                                                                  # Save return address
    sw      $s0,                            4($sp)                                                                  # Save $s0 (array address)
    sw      $s1,                            8($sp)                                                                  # Save $s1 (counter)
    sw      $s2,                            12($sp)                                                                 # Save $s2 (first pointer value)
    sw      $s3,                            16($sp)                                                                 # Save $s3 (second pointer value)
    sw      $t0,                            20($sp)                                                                 # Save $t0 (temporary)
    sw      $t1,                            24($sp)                                                                 # Save $t1 (temporary)
    sw      $t2,                            28($sp)                                                                 # Save $t2 (temporary)
    sw      $t3,                            32($sp)                                                                 # Save $t3 (temporary)

    move    $s0,                            $a2                                                                     # Load array address
    move    $t0,                            $a0                                                                     # Load first pointer address
    move    $t1,                            $a1                                                                     # Load second pointer address
    lw      $s2,                            0($t0)                                                                  # Load first pointer value
    lw      $s3,                            0($t1)                                                                  # Load second pointer value

    # Print "0:" label
    li      $v0,                            SysPrintString
    la      $a0,                            zero_label                                                              # Print "0:"
    syscall

    # Calculate position for first pointer (multiply by 4 since each element is 4 bytes)
    sll     $t2,                            $s2,                                        2                           # Multiply by 4
    addi    $t2,                            $t2,                                        -2                           # Add 2 for "0:" plus 1 space

    # Print spaces before caret for first pointer
    li      $s1,                            0                                                                       # Space counter
print_first_pointer_spaces:
    bge     $s1,                            $t2,                                        print_first_pointer_caret
    li      $v0,                            SysPrintString
    la      $a0,                            space                                                                   # Print space
    syscall
    addi    $s1,                            $s1,                                        1
    j       print_first_pointer_spaces

print_first_pointer_caret:
    li      $v0,                            SysPrintString
    la      $a0,                            caret                                                                   # Print "^"
    syscall

    # Print newline
    li      $v0,                            SysPrintString
    la      $a0,                            newline
    syscall

    # Print "1:" label
    li      $v0,                            SysPrintString
    la      $a0,                            one_label                                                               # Print "1:"
    syscall

    # Calculate position for second pointer
    sll     $t3,                            $s3,                                        2                           # Multiply by 4
    addi    $t3,                            $t3,                                       -2                           # Add 2 for "1:" plus 1 space

    # Print spaces before caret for second pointer
    li      $s1,                            0                                                                       # Space counter
print_second_pointer_spaces:
    bge     $s1,                            $t3,                                        print_second_pointer_caret
    li      $v0,                            SysPrintString
    la      $a0,                            space                                                                   # Print space
    syscall
    addi    $s1,                            $s1,                                        1
    j       print_second_pointer_spaces

print_second_pointer_caret:
    li      $v0,                            SysPrintString
    la      $a0,                            caret                                                                   # Print "^"
    syscall

    # Print newline
    li      $v0,                            SysPrintString
    la      $a0,                            newline
    syscall

    # Print "a:" label
    li      $v0,                            SysPrintString
    la      $a0,                            array_label                                                             # Print "a:"
    syscall

    # Now print the array normally
    move    $a0,                            $s0
    jal     print_array                                                                                             # Call the existing print_array function

    # Restore registers
    lw      $ra,                            0($sp)
    lw      $s0,                            4($sp)
    lw      $s1,                            8($sp)
    lw      $s2,                            12($sp)
    lw      $s3,                            16($sp)
    lw      $t0,                            20($sp)
    lw      $t1,                            24($sp)
    lw      $t2,                            28($sp)
    lw      $t3,                            32($sp)
    addi    $sp,                            $sp,                                        36
    jr      $ra

#
