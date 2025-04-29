    .include    "SysCalls.asm"

.data 
.align  2
array:          .space      36      # 9 words (aligned)
firstpointer:   .word      0        # 4 bytes (aligned)
secpointer:     .word      0        # 4 bytes (aligned)
matrixpointer:  .space      144     # 36 words (aligned)
user_prompt:    .asciiz    "Enter index (1-9): "
pointer_prompt: .asciiz    "Enter pointer to move (0 for first, 1 for second): "
user_win_msg:   .asciiz    "User wins!\n"
comp_win_msg:   .asciiz    "Computer wins!\n"
invalid_move:   .asciiz    "Invalid move, try again.\n"

.text  
.globl  main

main:
    # Initialize game components
    la      $a0, array
    jal     init_array
    
    la      $a0, firstpointer
    la      $a1, secpointer
    jal     init_pointers
    
    la      $a0, matrixpointer
    jal     init_matrix

game_loop:
    # User's turn
user_turn:
    # Prompt for index
    li      $v0, SysPrintString
    la      $a0, user_prompt
    syscall
    
    li      $v0, SysReadInt
    syscall
    move    $a2, $v0            # Store index in $a2
    
    # Prompt for pointer selection
    li      $v0, SysPrintString
    la      $a0, pointer_prompt
    syscall
    
    li      $v0, SysReadInt
    syscall
    move    $a3, $v0            # Store pointer selection in $a3
    
    # Set up and call move_pointers for user
    la      $a0, firstpointer
    la      $a1, secpointer
    li      $t0, -2             # User action
    la      $t1, matrixpointer
    jal     move_pointers
    
    # Check if move was valid
    beq     $v0, 1, user_move_valid
    
    # Invalid move, try again
    li      $v0, SysPrintString
    la      $a0, invalid_move
    syscall
    j       user_turn
    
user_move_valid:
    # Check for winner after user move
    la      $a0, matrixpointer
    jal     check_matrix
    
    # If winner found (v0 != 0), end game
    bnez    $v0, game_over
    
    # Computer's turn
comp_turn:
    # Generate random index (1-9)
    li      $a1, 9
    li      $v0, SysRandInt
    syscall
    addi    $a2, $v0, 1         # Store random index (1-9) in $a2
    
    # Generate random pointer selection (0 or 1)
    li      $a1, 2
    li      $v0, SysRandInt
    syscall
    move    $a3, $v0            # Store random pointer selection in $a3
    
    # Set up and call move_pointers for computer
    la      $a0, firstpointer
    la      $a1, secpointer
    li      $t0, -1             # Computer action
    la      $t1, matrixpointer
    jal     move_pointers
    
    # Check if move was valid
    beq     $v0, 1, comp_move_valid
    
    # Invalid move, try again
    j       comp_turn
    
comp_move_valid:
    # Check for winner after computer move
    la      $a0, matrixpointer
    jal     check_matrix
    
    # If no winner found (v0 == 0), continue game
    beqz    $v0, game_loop
    
game_over:
    # Determine winner based on v1 from check_matrix
    beq     $v1, -2, user_wins
    beq     $v1, -1, computer_wins
    
    # Shouldn't reach here if check_matrix works correctly
    j       exit
    
user_wins:
    li      $v0, SysPrintString
    la      $a0, user_win_msg
    syscall
    j       exit
    
computer_wins:
    li      $v0, SysPrintString
    la      $a0, comp_win_msg
    syscall

exit:
    # Print final matrix state
    la      $a0, matrixpointer
    jal     print_matrix
    
    # Print pointer values
    la      $a0, firstpointer
    la      $a1, secpointer
    la      $a2, array
    jal     print_pointers
    
    li      $v0, SysExit
    syscall
