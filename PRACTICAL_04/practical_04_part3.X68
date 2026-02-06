*-----------------------------------------------------------
* Title      : practical_04_part3
* Written by : Kamil Salih
* Date       : 06/02/2026
* Description: Uses subroutine and unconditional branches (BSR and BRA) to control game flow, simulating taking damage, picking up health, and ending the game by updating a health value stored in memory via an address register.
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    ; Move Health to Memory Location $3000
    MOVE.B  #100, $3000
    
    ; Load Memory Address $3000 into
    ; Address Register A1
    LEA     $3000, A1
    
    ; Branch to TAKING_DAMAGE
    BSR     TAKING_DAMAGE
    
BACK_IN_THE_GAME:
    ; Let's Help this player out
    BSR     HEALTH_PICKUP
    BRA     GAME_END
    
TAKING_DAMAGE:
    ; Hit by NPC
    ; Non Player Character
    SUB.B   #20, (A1)
    BRA     BACK_IN_THE_GAME
    
HEALTH_PICKUP:
    ; Pickup Health Found
    ADD.B   #10, (A1)
    RTS
    
GAME_END:
    ; Game Over
    MOVE.W  #$500, (A1)

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source
    

;Review questions, what are the Branch Instructions useful for BRA and BSR, what Addressing Modes are used?
;BRA: used for unconditional program flow control by jumping to another label
;BSR branches to a subroutine and saves the return address so execution can return using RTS

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
