*-----------------------------------------------------------
* Title      : practical_06_part6
* Written by : Kamil Salih
* Date       : 27/02/2026
* Description: This program compares two player positions stored on the stack and subtracts 10 from the HEALTH variable if they are equal, then displays the remaining health before halting.
*-----------------------------------------------------------
        ORG     $1000
START:

        MOVE.L  #HEALTH, -(SP)    ; Note position in Stack

        MOVE.B  #14, D0
        MOVE.B  #14, D1

        MOVE.L  D0, -(SP)         ; Player X
        MOVE.L  D1, -(SP)         ; Enemy X

        JSR     GAME_LOOP
        BSR     HEADS_UP_DISPLAY
        BRA     END_GAME


GAME_LOOP:

        MOVE.L  4(SP), D1         ; Note depth in Stack
        MOVE.L  8(SP), D0         ; Note depth in Stack

        CMP     D0, D1
        BEQ     DAMAGE
        BRA     NO_DAMAGE


DAMAGE:
        MOVEA.L 12(SP), A1        ; Note depth in Stack
        SUB.B   #10, (A1)

NO_DAMAGE:
        RTS


HEADS_UP_DISPLAY:
        MOVE.B  HEALTH, D1
        MOVE.B  #3, D0
        TRAP    #15
        RTS


END_GAME

        SIMHALT                  ; halt simulator


HEALTH: DC.B 100

        END     START
        
        
;Review questions moving around stack can be achieved by what means other than push and pop, what problems could this cause?

;You can move around the stack without push/pop by:
;Using offset addressing (e.g., 4(SP))
;Manually adjusting SP (ADD.L #4, SP)
;Using a frame pointer (A6 with LINK/UNLK)
;Moving data directly between stack locations

;Problems this can cause:
;Wrong offsets if stack depth changes
;Overwriting the return address
;Crashes or unpredictable behavior
;Hard-to-maintain, fragile code
;Alignment errors

;Main risk: incorrect stack depth assumptions.

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
