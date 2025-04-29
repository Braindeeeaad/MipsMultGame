    .include    "SysCalls.asm"

.data 
.align  2
array:          .space      36      # 9 words (aligned)
firstpointer:   .word      0        # 4 bytes (aligned)
secpointer:     .word      0        # 4 bytes (aligned)
matrixpointer:  .space      144     # 36 words (aligned)

.text  
                    .globl      main
main:
    la      $a0,                            array
    jal     init_array
    #jal print_array
    la      $a0,                            firstpointer
    la      $a1,                            secpointer
    jal     init_pointers


    la      $a0,                            matrixpointer                                                           # Load matrix pointer address
    jal     init_matrix                                                                                             # Initialize with our data

    la      $a0,                            firstpointer
    la      $a1,                            secpointer
    la      $a2,                            3
    la      $a3,                            4
    li      $t0,                            -2
    la      $t1,                            matrixpointer
    jal     move_pointers

    la      $a0,                            matrixpointer
    jal     print_matrix



    la      $a0,                            firstpointer
    la      $a1,                            secpointer
    la      $a2,                            array
    jal     print_pointers
    li      $v0,                            SysExit
    syscall


