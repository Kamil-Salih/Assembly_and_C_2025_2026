*-----------------------------------------------------------
* Title      : practical_03_part4
* Written by : Kamil Salih
* Date       : 29/01/2026
* Description: initializes game-related data by storing various player and boss attributes of different sizes sequentially in memory starting at address $4000 using a single address register with proper offsets
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    LEA     $4000, A1
    
    MOVE.B  #100, (A1)      ;Player health
    MOVE.W  #1500, 2(A1)    ;Player points
    MOVE.W  #120, 4(A1)   ;Player X position
    MOVE.W  #140, 6(A1)     ;Player Y position
    MOVE.L  #100000, 8(A1)    ;Boss health (bullet sponge)
    MOVE.W  #160, 12(A1)    ; Boss X position
    MOVE.W  #180, 14(A1)    ; Boss Y position
    MOVE.L  #250000, 16(A1) ;High score
    MOVE.B  #5, 20(A1)      ;Respawn time
    MOVE.B  #10, 22(A1)      ;Starter weapon damage
    MOVE.W  #280, 24(A1)     ;Legendary weapon X position
    MOVE.W  #300, 26(A1)     ;Legendary weapon Y position
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
