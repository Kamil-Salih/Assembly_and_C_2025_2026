*-----------------------------------------------------------
* Title      : practical_05_part2
* Written by : Kamil Salih
* Date       : 10/02/2026
* Description: The program loads the player and enemy positions, sets D1 = 50 and D2 = 0, then checks for a collision by comparing D2 and D1. If they are equal, it jumps to GAME_OVER and halts
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    LEA PLAYER_POSITION, A1
    LEA ENEMY_POSITION, A2
    
    MOVE.B  #50, D1
    MOVE.B  #0, D2
    
COLLISION_CHECK:
    CMP D2, D1
    BLT NEXT_MOVE
    BEQ COLLISION
    
COLLISION:
    BRA GAME_OVER
    
GAME_OVER

    SIMHALT             ; halt simulator

* Put variables and constants here

PLAYER_POSITION:    DC.B 10, 15
ENEMY_POSITION:     DC.B 50, 55

    END    START        ; last line of source
    
    
;Review questions, what do the BEQ instructions mean, what Addressing Modes are used?
;BEQ: Branches if the previous comparison is equal (Z flag set).
;Addressing Modes: Immediate (#value), Register (D1, D2), and Register Indirect (LEA label, A1).


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
