                .include    "SysCalls.asm"

.data
                .align      2
array:          .space      36                                                      # 9 words (aligned)
firstpointer:   .word       0                                                       # 4 bytes (aligned)
secpointer:     .word       0                                                       # 4 bytes (aligned)
matrixpointer:  .space      144                                                     # 36 words (aligned)
user_prompt:    .asciiz     "Enter index (1-9): "
pointer_prompt: .asciiz     "Enter pointer to move (0 for first, 1 for second): "
user_win_msg:   .asciiz     "User wins!\n"
comp_win_msg:   .asciiz     "Computer wins!\n"
invalid_move:   .asciiz     "Invalid move, try again.\n"

.text
                .globl      main

main:
    # Initialize game components
    la      $a0,                array
    jal     init_array

    la      $a0,                firstpointer
    la      $a1,                secpointer
    jal     init_pointers

    la      $a0,                matrixpointer
    jal     init_matrix

    la      $a0,                matrixpointer
    jal     print_matrix



    la      $a0,                firstpointer
    la      $a1,                secpointer
    la      $a2,                array
    jal     print_pointers
    jal print_newline

game_loop:
    # User's turn
user_turn:
    # Prompt for index
    li      $v0,                SysPrintString
    la      $a0,                user_prompt
    syscall

    li      $v0,                SysReadInt
    syscall
    move    $a2,                $v0                                                 # Store index in $a2

    # Prompt for pointer selection
    li      $v0,                SysPrintString
    la      $a0,                pointer_prompt
    syscall

    li      $v0,                SysReadInt
    syscall
    move    $a3,                $v0                                                 # Store pointer selection in $a3
    beq     $a3,                $zero,              user_turn_first
    j       user_turn_sec
user_turn_first:
    la      $a3,                secpointer
    lw      $a3,                0($a3)
    j       user_turn_rest
user_turn_sec:
    move    $a3,                $a2
    la      $a2,                firstpointer
    lw      $a2,                0($a2)
    j       user_turn_rest
user_turn_rest:
    # Set up and call move_pointers for user
    la      $a0,                firstpointer
    la      $a1,                secpointer
    li      $t0,                -2                                                  # User action
    la      $t1,                matrixpointer
    jal     move_pointers

    # Check if move was valid
    beq     $v0,                1,                  user_move_valid

    # Invalid move, try again
    li      $v0,                SysPrintString
    la      $a0,                invalid_move
    syscall
    j       user_turn

user_move_valid:
    # Check for winner after user move
    la      $a0,                matrixpointer
    jal     print_matrix



    la      $a0,                firstpointer
    la      $a1,                secpointer
    la      $a2,                array
    jal     print_pointers
    jal print_newline
    la      $a0,                matrixpointer
    jal     check_matrix

    # If winner found (v0 != 0), end game
    bnez    $v0,                game_over

    # Computer's turn
comp_turn:
    # Initialize loop through matrix (6x6 = 36 elements)
    la      $t0,                matrixpointer                                       # Matrix base address
    li      $t1,                36                                                  # Total elements
    li      $t2,                0                                                   # Current index

comp_loop:
    # Check if we've processed all elements
    bge     $t2,                $t1,                comp_no_valid_move

    # Load current matrix value
    lw      $t3,                0($t0)                                              # $t3 = matrix[i]

    # Check if value is non-negative
    bltz    $t3,                comp_next_element

    # Try firstpointer division first
    lw      $t4,                firstpointer                                        # Load firstpointer value
    beqz    $t4,                comp_try_second                                     # Skip if firstpointer is 0

    div     $t3,                $t4                                                 # matrix[i] / firstpointer
    mfhi    $t5                                                                     # Remainder
    mflo    $t6                                                                     # Quotient

    # Check if remainder is 0 and quotient is in [1,9]
    bnez    $t5,                comp_try_second
    blt     $t6,                1,                  comp_try_second
    bgt     $t6,                9,                  comp_try_second

    # Valid move found - prepare to move secpointer to quotient
    # Parameters for move_pointers:
    # $a0 = firstpointer addr, $a1 = secpointer addr
    # $a2 = new firstpointer val, $a3 = new secpointer val
    # $t0 = action type (-1 for computer), $t1 = matrixpointer addr

    la      $a0,                firstpointer                                        # Keep firstpointer address
    la      $a1,                secpointer                                          # secpointer address
    lw      $a2,                firstpointer                                        # Keep firstpointer value
    move    $a3,                $t6                                                 # New secpointer value (quotient)
    li      $t0,                -1                                                  # Computer action
    la      $t1,                matrixpointer                                       # Matrix pointer

    jal     move_pointers

    # Check if move was successful
    beq     $v0,                1,                  comp_move_valid

    # If move failed, try second pointer
    j       comp_try_second

comp_try_second:
    # Try secpointer division
    lw      $t4,                secpointer                                          # Load secpointer value
    beqz    $t4,                comp_next_element                                   # Skip if secpointer is 0

    div     $t3,                $t4                                                 # matrix[i] / secpointer
    mfhi    $t5                                                                     # Remainder
    mflo    $t6                                                                     # Quotient

    # Check if remainder is 0 and quotient is in [1,9]
    bnez    $t5,                comp_next_element
    blt     $t6,                1,                  comp_next_element
    bgt     $t6,                9,                  comp_next_element

    # Valid move found - prepare to move firstpointer to quotient
    la      $a0,                firstpointer                                        # firstpointer address
    la      $a1,                secpointer                                          # secpointer address
    move    $a2,                $t6                                                 # New firstpointer value (quotient)
    lw      $a3,                secpointer                                          # Keep secpointer value
    li      $t0,                -1                                                  # Computer action
    la      $t1,                matrixpointer                                       # Matrix pointer

    jal     move_pointers

    # Check if move was successful
    beq     $v0,                1,                  comp_move_valid

comp_next_element:
    # Move to next matrix element
    addi    $t0,                $t0,                4
    addi    $t2,                $t2,                1
    j       comp_loop

comp_no_valid_move:
    # If no valid move found, computer passes
    li      $v0,                1                                                   # Indicate valid "pass" move
    j       comp_move_valid
comp_move_valid:
    # Check for winner after computer move
    la      $a0,                matrixpointer
    jal     print_matrix



    la      $a0,                firstpointer
    la      $a1,                secpointer
    la      $a2,                array
    jal     print_pointers
    jal print_newline
    la      $a0,                matrixpointer
    jal     check_matrix

    # If no winner found (v0 == 0), continue game
    beqz    $v0,                game_loop

game_over:
    # Determine winner based on v1 from check_matrix
    beq     $v1,                -2,                 user_wins
    beq     $v1,                -1,                 computer_wins

    # Shouldn't reach here if check_matrix works correctly
    j       exit

user_wins:
    li      $v0,                SysPrintString
    la      $a0,                user_win_msg
    syscall
    j       exit

computer_wins:
    li      $v0,                SysPrintString
    la      $a0,                comp_win_msg
    syscall

exit:
    # Print final matrix state
    la      $a0,                matrixpointer
    jal     print_matrix

    # Print pointer values
    la      $a0,                firstpointer
    la      $a1,                secpointer
    la      $a2,                array
    jal     print_pointers

    li      $v0,                SysExit
    syscall
