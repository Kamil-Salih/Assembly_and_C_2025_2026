*-----------------------------------------------------------
* Title      : practical_05_part3
* Written by : Kamil Salih
* Date       : 10/02/2026
* Description: The program simulates a simple game loop where the player moves and can take damage. 
*              Each loop, it updates the player’s position, checks for collisions with the enemy, and subtracts DAMAGE from PLAYER_HEALTH if a collision occurs. The game ends and halts when the player’s health reaches 0.
*-----------------------------------------------------------
    ORG    $1000
DAMAGE  EQU 100
START:                  ; first instruction of program
GAME_LOOP:
    LEA MSG_GAME_LOOP, A1
    MOVE.B  #13, D0
    TRAP    #15
    CMP.B   #0, PLAYER_HEALTH
    BEQ GAME_OVER
    BSR UPDATE
    BSR COLLISION_CHECK
    BRA GAME_LOOP
UPDATE:
    ADD.B   #1, PLAYER_POSITION
    RTS
COLLISION_CHECK:
    MOVE.B  PLAYER_POSITION, D1
    CMP.B   D2, D1
    BEQ     COLLISION
    RTS
COLLISION:
    SUB.B   #DAMAGE, PLAYER_HEALTH
    BRA     GAME_LOOP
GAME_OVER:
    LEA MSG_GAME_OVER, A1
    MOVE.B  #13, D0
    TRAP    #15
    SIMHALT             ; halt simulator

* Put variables and constants here
PLAYER_POSITION:    DC.B 10
ENEMY_POSITION:     DC.B 50
PLAYER_HEALTH:      DC.B 100

MSG_GAME_LOOP       DC.B    'Game Loop........',0
MSG_GAME_OVER       DC.B    'Game Over!',0

    END    START        ; last line of source
    
    
    
;Review questions, what are EQU, BEQ, LEA, TRAP #15, D0 used for within this code. How are MEMORY locations used. Register instructions mean, what Addressing Modes are used?
;EQU: Defines a constant value (DAMAGE EQU 100)
;BEQ: Branches if the previous comparison is equal (Zero flag set).
;LEA: Loads the address of a memory label into an address register (example: LEA MSG_GAME_LOOP, A1).
;TRAP #15: Calls a system or simulator routine (example: to print a message).
;D0:  A general-purpose data register used for calculations or passing values (example: message length #13).
;MEMORY: Variables like PLAYER_POSITION, PLAYER_HEALTH, and messages are stored in memory. Their addresses are used to read or update values during the program.
;Register instructions: Operations using registers, like MOVE.B, ADD.B, SUB.B, CMP.B, or RTS, manipulate data directly in CPU registers.
;Addressing Modes: 
    ;Immediate: #13 › literal value.
    ;Register Direct: D0, D1 › operate on registers.
    ;Register Indirect: A1 › access memory via address register.
    ;Absolute Memory/Direct: PLAYER_POSITION, PLAYER_HEALTH › specific memory locations.




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
