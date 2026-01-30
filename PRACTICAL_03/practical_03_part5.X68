*-----------------------------------------------------------
* Title      : practical_03_part5
* Written by : Kamil Salih
* Date       : 29/01/2026
* Description: This code sums the five 32-bit values stored in ACHIEVEMENT_POINTS and stores the total in register D0
*-----------------------------------------------------------
    ORG    $1000        ;sets the start address at memory location $1000
START:                  ; first instruction of program

* Put program code here
 
    MOVEA.L #ACHIEVEMENT_POINTS,    A1  ;loads address of ACHIEVEMENT_POINTS into address register A1
    MOVE.L  #0, D0                      ;Initializes data register D0 to zero (it will hold the sum)
    
    MOVE.L  (A1)+,  D2                  ; Loads the first 32 bit value from memory pointed by A1 into D2, and then increment A1 by 4 bytes
    ADD.L   D2, D0                      ;Adds value in D2 to accumulator D0
    
    MOVE.L  (A1)+,  D2                  ;Loads second 32 bit value and increment A1
    ADD.L   D2, D0                      ; Add value in D2 to D0
    
    MOVE.L  (A1)+,  D2                  ;Loads third 32 bit value and increment A1
    ADD.L   D2, D0                      ;Add value in D2 to D0
    
    MOVE.L  (A1)+,  D2                  ;Loads fourth 32 bit value and increment A1
    ADD.L   D2, D0                      ;Add value in D2 to D0
    
    MOVE.L  (A1)+,  D2                  ;Loads fifth 32 bit value and increment by A1
    ADD.L   D2, D0                      ;Add value in D2 to D0
    
    SIMHALT             ; halt simulator

* Put variables and constants here

ACHIEVEMENT_POINTS: DC.L    5,  10, 15, 20, 30  ;Defines 5 32 bit constants with specified values

    END:        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
