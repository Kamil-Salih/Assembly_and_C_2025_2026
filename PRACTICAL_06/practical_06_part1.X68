*-----------------------------------------------------------
* Title      : practical_06_part1
* Written by : Kamil Salih
* Date       : 27/02/2026
* Description: This program sets up a trap task using TRAP #15 to first initialize a service and then display the null-terminated string "Trap Task Test" stored in memory.
*-----------------------------------------------------------
        ORG     $1000

START:

        ; Move Trap Task to D0
        MOVE.B  #2, D0

        ; Interrupt and Trap Task
        TRAP    #15

        LEA     MESSAGE, A1
        MOVE.B  #13, D0
        TRAP    #15

END_PROG:

MESSAGE: DC.B    'Trap Task Test', 0
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
