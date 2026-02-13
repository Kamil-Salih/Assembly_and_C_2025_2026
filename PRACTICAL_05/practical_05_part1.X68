*-----------------------------------------------------------
* Title      : practical_05_part1
* Written by : Kamil Salih
* Date       : 10/02/2026
* Description: The program counts down D0 from 3, adding 10 to D1 each loop, and halts when D0 reaches 1
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

INITIALISE:
    MOVE.B  #3, D0
    MOVE.B  #0, D1
    
GAME_LOOP:
    CMP.B   #1, D0
    BNE GAME_POINTS
    BEQ GAME_OVER
    
GAME_POINTS:
    ADD.B   #10, D1
    SUB.B   #1, D0
    BRA     GAME_LOOP
    
    
GAME_OVER:

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


;Review questions, what is the purpose of CMP, BNE, BEQ and the Status Register. How many times does GAME_LOOP execute?

;CMP:     Compares two values by subtracting the source from the destination 
;         (D0 - 1). It does not store the result, but updates the condition 
;         codes in the Status Register (Z, N, V, C).

;BNE:     Branch if Not Equal. It branches when the Zero (Z) flag = 0 
;         (meaning the compared values are not equal).

;BEQ:     Branch if Equal. It branches when the Zero (Z) flag = 1 
;         (meaning the compared values are equal).

;Status Register:
;The Status Register contains condition flags affected by CMP:
;Z (Zero) – Set if result = 0 (values equal)
;N (Negative) – Set if result is negative
;V (Overflow) – Set if signed overflow occurs
;C (Carry) – Set if borrow occurs in subtraction
;In this program, CMP mainly affects the Z flag to control BNE and BEQ.

;How many times does GAME_LOOP execute?: 
;3 times


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
