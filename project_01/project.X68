*-----------------------------------------------------------
* Project Title: Alternative Physics: Facility Infiltration
* Student Name:  Kamil Salih
* Student ID:    C00307549
* Date:          05/03/2026 
* Description:   You’re a mercenary infiltrating a mysterious facility, battling physics-defying bosses to collect four artifacts and escape—or face death.
* Known Bugs:    None
*-----------------------------------------------------------

	ORG $1000	;STARTING MEMORY ADDRESS FOR THE PROGRAM $1000

*-------------------------------------------------------
* CONSTANTS
*-------------------------------------------------------
EXIT            EQU 0
MAX_HEALTH      EQU 100
MAX_ENERGY      EQU 100
MAX_AMMO        EQU 5
NUM_ARTIFACTS   EQU 4

GLASS_CANNON_HEALTH   EQU 50
MOMENTUM_THIEF_HEALTH EQU 100
ENTROPY_LEECH_HEALTH  EQU 100
FORCE_INVERTER_HEALTH EQU 150

PLAYER_ACTION   EQU $4070
SKIP_BOSS_TURN  EQU $4063

BOSS1_DEAD      EQU $4020
BOSS2_DEAD      EQU $4021
BOSS3_DEAD      EQU $4022
BOSS4_DEAD      EQU $4023

*-------------------------------------------------------
* RESET GAME (Soft Reset)
*-------------------------------------------------------
RESET_GAME:
    ; Player stats
    MOVE.B  #MAX_HEALTH, $4000      ; player health
    MOVE.B  #MAX_ENERGY, $4001      ; energy sword
    MOVE.B  #MAX_AMMO,   $4002      ; ammo
    MOVE.B  #0, $4003               ; artifacts

    ; Weather + turn state
    MOVE.B  #0, $4004               ; fog penalty
    MOVE.B  #0, $4005               ; turn counter
    MOVE.B  #0, $4006               ; weather type (0=rain,1=sun,2=fog)

    ; Boss mechanics state
    CLR.W   $4008                   ; momentum stored damage (word) — aligned even
    MOVE.B  #0, $4061               ; current boss selection
    MOVE.B  #0, $4062               ; last player damage
    MOVE.B  #0, SKIP_BOSS_TURN      ; rifle skip counter
    MOVE.B  #0, $4064               ; temp: previous energy at start of boss phase

    ; Boss HP (words)
    MOVE.W  #GLASS_CANNON_HEALTH,   $4010
    MOVE.W  #MOMENTUM_THIEF_HEALTH, $4012
    MOVE.W  #ENTROPY_LEECH_HEALTH,  $4014
    MOVE.W  #FORCE_INVERTER_HEALTH, $4016

    ; Boss defeated flags
    MOVE.B  #0, BOSS1_DEAD
    MOVE.B  #0, BOSS2_DEAD
    MOVE.B  #0, BOSS3_DEAD
    MOVE.B  #0, BOSS4_DEAD
    RTS

*-------------------------------------------------------
* START
*-------------------------------------------------------
START:
    BSR RESET_GAME
    BSR WELCOME

    ; print "You approach the facility..." once
    LEA GAMEPLAY_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    BSR CONTINUE

    BSR SELECT_BOSS_IF_NONE
    BSR GAME
    SIMHALT
    RTS

*-------------------------------------------------------
*-------------------GAME SUBROUTINE---------------------
*-------------------------------------------------------
GAME:
    BSR     GAMELOOP        ;BRANCH TO GAMELOOP SUBROUTINE
    RTS                     ;RETURN FROM GAME: SUBROUTINE
          
END:
    SIMHALT

*-------------------------------------------------------
*-------------------WELCOME SUBROUTINE------------------
*-------------------------------------------------------
WELCOME:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    LEA     WELCOME_MSG,A1  ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     CONTINUE        ;BRANCH TO CONTINUE SUBROUTINE 
    RTS                     ;RETURN FROM WELCOME: SUBROUTINE

*-------------------------------------------------------
*---------GAMEPLAY INPUT VALUES SUBROUTINE--------------
*-------------------------------------------------------    
INPUT:
    BSR     POTIONS         ;BRANCH TO POTION INPUT SUBROUTINE
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     CONTINUE        ;BRANCH TO CONTINUE SUBROUTINE
    BSR     WEAPONS         ;BRANCH TO WEAPONS INPUT SUBROUTINE
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     CONTINUE        ;BRANCH TO CONTINUE SUBROUTINE
    RTS

*-------------------------------------------------------
*----------------GAMELOOP (MAIN LOOP)-------------------
*------------------------------------------------------- 
GAMELOOP:
    BSR     INPUT           ;BRANCH TO INPUT SUBROUTINE
    BSR     UPDATE          ;BRANCH TO UPDATE GAME SUBROUTINE 
    ;BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN 
    BSR     DRAW            ;BRANCH TO DRAW GAME SUBROUTINE               
    ;BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN 
    BSR     GAMEPLAY        ;BRANCH TO GAMEPLAY SUBROUTINE
    ;BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN        
    BSR     HUD             ;BRANCH TO HUD SUBROUTINE
    ;BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN
    BSR     REPLAY          ;BRANCH TO REPLAY SUBROUTINE 
    BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN
    RTS                     ;RETURN FROM GAMELOOP: SUBROUTINE       

*-------------------------------------------------------
*----------------UPDATE QUEST PROGRESS------------------
*  COMPLETE QUEST
*------------------------------------------------------- 
UPDATE:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE   
    LEA     UPDATE_MSG,A1   ;ASSIGN MESSAGE TO ADDRESS REGISTER A1 
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    RTS                     

*-------------------------------------------------------
*-----------------DRAW QUEST UPDATES--------------------
* DRAW THE GAME PROGRESS INFORMATION, STATUS REGARDING
* QUEST
*------------------------------------------------------- 
DRAW:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE            
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE    
    LEA     DRAW_MSG,A1     ;ASSIGN MESSAGE TO ADDRESS REGISTER A1     
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    RTS                     ;RETURN FROM DRAW: SUBROUTINE

*-------------------------------------------------------
*---GAME PLAY (QUEST PROGRESS)--------------------------
*------------------------------------------------------- 
GAMEPLAY:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    LEA     GAMEPLAY_MSG,A1 ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    MOVE.B  #4,D0           ;MOVE LITERAL 4 TO DO               
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    BSR     COLLISION       ;BRANCH TO COLLISION SUBROUTINE
    RTS                     ;RETURN FROM GAMEPLAY: SUBROUTINE

*-------------------------------------------------------
*-----------------HEADS UP DISPLAY (SCORE)--------------
*-------------------------------------------------------   
HUD:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    LEA     HUD_MSG,A1      ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    MOVE.B  (A3),D1         ;RETRIEVE THE VALUE A3 POINT TO AND MOVE TO D1
    MOVE.B  #3,D0           ;MOVE LITERAL 3 TO DO    
    TRAP    #15               
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE    
    RTS                     

*-------------------------------------------------------
*-----------------------BEING ATTACKED------------------
* THIS COULD BE USED FOR COLLISION DETECTION
*-------------------------------------------------------
COLLISION:                  
    MOVE.B  #DANGER_LOC,D1  ;MOVE LITERAL DANGER_LOC TO D1
    CMP     #100,D1         ;  IS( X == 100)?
    BNE     COLLISION_MISS  ;  IF NOT, BRANCH TO COLLISION_MISS
    BSR     COLLISION_HIT   ;  ELSE, BRANCH TO COLLISION_HIT
    RTS                     ;RETURN FROM COLLISION: SUBROUTINE  
COLLISION_HIT:
    LEA     HIT_MSG,A1      ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE    #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    RTS                     ;RETURN FROM COLLISION_HIT: SUBROUTINE
    
COLLISION_MISS:
    LEA     MISS_MSG,A1		;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE    #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    RTS                     ;RETURN FROM COLLISION_MISS: SUBROUTINE

*-------------------------------------------------------
*--------------------------LOOP-------------------------
*-------------------------------------------------------
LOOP:
    MOVE.B  #5, D3          ;LOOP COUNTER D3=5
NEXT:
    LEA     LOOP_MSG,A1     ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO          
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    SUB     #1,D3           ;DECREMENT LOOP COUNTER
    BNE     NEXT            ;REPEAT UNTIL D0=0

*-------------------------------------------------------
*------------------SCREEN DECORATION--------------------
*-------------------------------------------------------
DECORATE:
    MOVE.B  #60, D3         ;LOOP COUNTER D3=60
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
OUT:
    LEA     LOOP_MSG,A1     ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    SUB     #1,D3           ;DECREMENT LOOP COUNTER
    BNE     OUT             ;REPEAT UNTIL D0=0
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    RTS                     ;RETURN FROM DECORATE: SUBROUTINE
    
CLEAR_SCREEN: 
    MOVE.B  #11,D0          ;CLEAR SCREEN
    MOVE.W  #$FF00,D1       ;SET COLOUR
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    RTS                     ;RETURN FROM CLEAR_SCREEN: SUBROUTINE                

*-------------------------------------------------------
*------------------------REPLAY-------------------------
*-------------------------------------------------------
REPLAY:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    LEA     REPLAY_MSG,A1   ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    
    MOVE.B  #4,D0           ;MOVE LITERAL 4 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0

    CMP     #EXIT,D1        ;COMPARE D1 TO EXIT
    BEQ     END             ;IF EQUAL, BRANCH TO END
    BSR     GAMELOOP        ;BRANCH TO GAMELOOP SUBROUTINE
    
*-------------------------------------------------------
*------------------------CONTINUE-------------------------
*-------------------------------------------------------
CONTINUE:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    LEA     CONTINUE_MSG,A1 ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    
    MOVE.B  #4,D0           ;MOVE LITERAL 4 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    RTS                     ;RETURN FROM SUBROUTINE 

ENDL:
    MOVEM.L D0/A1,-(A7)     ;SAVE D0 AND A1
    MOVE    #14,D0          ;MOVE LITERAL 14 TO DO
    LEA     CRLF,A1         ;ASSIGN CRLF TO ADDRESS REGISTER A1
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    MOVEM.L (A7)+,D0/A1     ;RESTORE D0 AND A1
    RTS                     ;RETURN FROM ENDL: SUBROUTINE
    
*-------------------------------------------------------
*-------------------DATA DECLARATIONS--------------------
*-------------------------------------------------------

CRLF:           DC.B    $0D,$0A,0






    END START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~




