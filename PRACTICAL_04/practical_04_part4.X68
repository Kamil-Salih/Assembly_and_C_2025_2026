*-----------------------------------------------------------
* Title      : practical_04_part4
* Written by : Kamil Salih
* Date       : 06/02/2026
* Description: The program simulates a simple turn of a game where the player attacks the boss and the boss attacks the player, updating health and flags using arithmetic, logical, and branch instructions.
*-----------------------------------------------------------
    ORG    $1000        ; starting memory address is $1000
START:                  ; first instruction of program

* Put program code here

    MOVE.B  #100, $3000 ;Player health (100)
    MOVE.W  #500, $3002 ;Player points (500)
    MOVE.B  #80,  $3004 ;Player X position
    MOVE.B  #100, $3005 ;Player Y position
    MOVE.B  #$96, $3006 ;Boss health (150)
    MOVE.B  #120, $3007 ;Boss X position
    MOVE.B  #140, $3008 ;Boss Y position

    LEA $3000, A0       ; A1 points to start of game data
    
    BSR     PLAYER_ATTACK   ;runs player attack
    BSR     BOSS_ATTACK     ;runs boss attack
    BRA     GAME_END        ; jumps to the end of the program
    
PLAYER_ATTACK:
    SUB.B   #15, 6(A0)      ; Boss loses health
    
    AND.B   #$0F, 6(A0)       ; keeps only the bottom 4 bits of the number. It shows a logical operation without affecting the game too much
    RTS
    
BOSS_ATTACK:
    SUB.B   #10, (A0)       ; Player loses health

    OR.B    #$01, (A0)      ; Set damage flag (set the lowest bit (bit 0) to 1). It could mean the player was attacked, or an event happened (if it is set to one, it should not be changed)
    EOR.B   #$02, (A0)      ; Toggle effect (indicates something happened but it can be changed again in case another event happens). It’s #$02 because we want to flip only bit 1 to toggle a flag or effect without changing the other bits.
    RTS                     ;return

    
GAME_END:
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


;Review questions what Addressing Modes are used?
;Addressing Modes: immediate, direct, and indirect

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
