*-----------------------------------------------------------
* Title      : practical_05_part5
* Written by : Kamil Salih
* Date       : 12/02/2026
* Description: This program is a simple 68000 game loop that moves a player along the X axis, checks for collisions with enemies stored in an array, reduces health on collision, and ends the game when health reaches zero.
*-----------------------------------------------------------
        ORG     $1000 

; D0 Used for Trap Codes, And Counting
; D1 Used for Players Health
; D2 Used for Positions
; D4 used for count
; D5 loop counter
; A0 for counting
; A1 for messages
; A2 used for PLAYER_X
; A3 used for positions arrays

DAMAGE      EQU 10
POWER_GAIN  EQU 10

START:
        LEA     PLAYER_X, A2
        LEA     ENEMY_POSITIONS, A3
        BRA     GAME_LOOP

GAME_LOOP:
        BSR     COUNT_ENEMIES
        MOVE.B  D0, D4

        LEA     MSG_GAMELOOP, A1
        BSR     DRAW

        BSR     UPDATE
        BRA     GAME_LOOP

UPDATE:
        MOVE.B  PLAYER_HEALTH, D1

        LEA     MSG_HEALTH, A1
        BSR     DRAW

        MOVE.B  #3, D0
        TRAP    #15

        LEA     CRLF, A1
        BSR     DRAW

        CMP     #0, D1
        BLE     GAME_OVER

        ADD.L   #1, PLAYER_X      ; Changed for maintainability

        BSR     COLLISION
        BSR     POWERUP_CHECK     ; Added power-up check
        RTS

DRAW:
        MOVE.B  #13, D0
        TRAP    #15
        RTS

; =========================
; COLLISION (UNCHANGED)
; =========================
COLLISION:
        MOVE.B  #1, D5
        LEA     ENEMY_POSITIONS, A3

ITERATE:
        CMP     D5, D4
        ADD.B   #1, D5
        BEQ     GAME_LOOP
        BNE     CHECK_ENEMIES
        RTS
        
CHECK_ENEMIES:
        MOVE.L      (A3)+, D2
        MOVE.L      PLAYER_X, D3   ; maintainable version

        CMP.L       D2, D3
        BEQ         REDUCE_HEALTH
        BNE         ITERATE

REDUCE_HEALTH:
        LEA         MSG_COLLISION, A1
        BSR         DRAW

        SUB.B       #DAMAGE, PLAYER_HEALTH

        LEA         MSG_DAMAGE, A1
        BSR         DRAW
        BRA         GAME_LOOP

; =========================
; POWER UP CHECK (Same Structure as COLLISION)
; =========================
POWERUP_CHECK:
        MOVE.B  #1, D5
        LEA     POWER_UPS, A3

POWER_ITERATE:
        TST.L   (A3)
        BEQ     END_POWER

        MOVE.L  (A3)+, D2
        MOVE.L  PLAYER_X, D3

        CMP.L   D2, D3
        BEQ     INCREASE_HEALTH
        BRA     POWER_ITERATE

INCREASE_HEALTH:
        LEA     MSG_POWER, A1
        BSR     DRAW

        ADD.B   #POWER_GAIN, PLAYER_HEALTH
        BRA     GAME_LOOP

END_POWER:
        RTS

GAME_OVER:
        LEA     MSG_GAMEOVER, A1
        BSR     DRAW
        SIMHALT

COUNT_ENEMIES:
        MOVE.B      #0, D0
        LEA         ENEMY_POSITIONS, A0

COUNT_ENEMIES_LOOP:
        TST.L       (A0)+
        BEQ         END_COUNTING

        ADD.B       #1, D0
        BRA         COUNT_ENEMIES_LOOP

END_COUNTING:
        RTS

; =========================
; DATA
; =========================
PLAYER_X        DC.L    1
PLAYER_HEALTH   DC.B    100

MSG_HEALTH      DC.B    'Health : ', 0
MSG_GAMELOOP    DC.B    'Game Loop', 0
MSG_COLLISION   DC.B    'Collision', 0
MSG_GAMEOVER    DC.B    'Game Over', 0
MSG_DAMAGE      DC.B    'Taking Damage', 0
MSG_POWER       DC.B    'Power Up!', 0
CRLF            DC.B    $0D,$0A,0

ENEMY_POSITIONS DC.L    20,30,40,50,60,70,80,90,200,300,500,0
POWER_UPS       DC.L    10,55,220,0

        END     START
        
        
;TST.L:
;Tests a long word operand by comparing it to zero.
;It does not change the operand, but updates the condition codes (Z, N, V, C).
;Used to check if a value is zero, negative, or positive.
;In this program it is used to detect the end of a zero-terminated array.

;Addressing Modes:
;Address Register Indirect with Postincrement  (example: (A0)+)
;Address Register Indirect                     (example: (A3))
;Data Register Direct                          (example: D0)
;Absolute Addressing                           (example: PLAYER_X)


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
