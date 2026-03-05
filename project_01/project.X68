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
* CHECK WIN
*-------------------------------------------------------
CHECK_WIN:
    MOVE.B $4003, D0
    CMP.B #NUM_ARTIFACTS, D0
    BEQ WIN_TRUE
    MOVE.B #0, D0
    RTS

WIN_TRUE:
    MOVE.B #1, D0
    RTS

*-------------------------------------------------------
* GAME
*-------------------------------------------------------
GAME:
MAIN_LOOP:
    BSR CHECK_WIN
    CMP.B #1, D0
    BEQ END_GAME

    BSR GAMELOOP
    BRA MAIN_LOOP

END_GAME:
    LEA WIN_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    SIMHALT
    RTS

*-------------------------------------------------------
* WELCOME (only at start)
*-------------------------------------------------------
WELCOME:
    LEA WELCOME_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    BSR CONTINUE
    RTS

*-------------------------------------------------------
* RANDOM NUMBER (0–2)
*-------------------------------------------------------
RANDOM_NUMBER:
    MOVE.W #8, D0
    TRAP #15
    MOVE.W D1, D0
    ANDI.W #3, D0
    CMP.W #3, D0
    BNE RN_OK
    MOVE.W #2, D0
RN_OK:
    RTS

*-------------------------------------------------------
* SELECT_BOSS_IF_NONE (with validation 1–4)
*-------------------------------------------------------
SELECT_BOSS_IF_NONE:
    MOVE.B $4061, D0
    CMP.B #1, D0
    BLT SB_NEED_SELECT
    CMP.B #4, D0
    BGT SB_NEED_SELECT
    RTS
SB_NEED_SELECT:
    BSR SELECT_BOSS
    RTS

*-------------------------------------------------------
* BOSS INPUT LOOP
*-------------------------------------------------------
BOSS_INPUT_LOOP:
    CLR.B INPUT_BUFFER
    MOVE.W #2, D0
    LEA INPUT_BUFFER, A1
    TRAP #15

    MOVE.B (INPUT_BUFFER), D1
    SUB.B #'0', D1

    CMP.B #1, D1
    BLT INVALID_BOSS_INPUT
    CMP.B #4, D1
    BGT INVALID_BOSS_INPUT

    CMP.B #1, D1
    BEQ CHK_B1
    CMP.B #2, D1
    BEQ CHK_B2
    CMP.B #3, D1
    BEQ CHK_B3
    CMP.B #4, D1
    BEQ CHK_B4

CHK_B1:
    MOVE.B BOSS1_DEAD, D2
    CMP.B #1, D2
    BEQ BOSS_ALREADY_DEAD
    BRA BOSS_OK

CHK_B2:
    MOVE.B BOSS2_DEAD, D2
    CMP.B #1, D2
    BEQ BOSS_ALREADY_DEAD
    BRA BOSS_OK

CHK_B3:
    MOVE.B BOSS3_DEAD, D2
    CMP.B #1, D2
    BEQ BOSS_ALREADY_DEAD
    BRA BOSS_OK

CHK_B4:
    MOVE.B BOSS4_DEAD, D2
    CMP.B #1, D2
    BEQ BOSS_ALREADY_DEAD
    BRA BOSS_OK

BOSS_ALREADY_DEAD:
    LEA BOSS_DEAD_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    BRA BOSS_INPUT_LOOP

BOSS_OK:
    MOVE.B D1, $4061
    RTS

INVALID_BOSS_INPUT:
    LEA INVALID_BOSS_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    BRA BOSS_INPUT_LOOP

*-------------------------------------------------------
* SELECT BOSS
*-------------------------------------------------------
SELECT_BOSS:
    BSR CHECK_WIN
    CMP.B #1, D0
    BEQ ALL_BOSSES_DEFEATED

    LEA BOSS_SELECT_MSG, A1
    MOVE.W #13, D0
    TRAP #15

    BSR BOSS_INPUT_LOOP

    MOVE.B $4061, D0
    CMP.B #1, D0
    BEQ SHOW_BOSS1
    CMP.B #2, D0
    BEQ SHOW_BOSS2
    CMP.B #3, D0
    BEQ SHOW_BOSS3
    CMP.B #4, D0
    BEQ SHOW_BOSS4
    RTS

SHOW_BOSS1:
    LEA BOSS1_MSG, A1
    BRA SHOW_BOSS_MSG
SHOW_BOSS2:
    LEA BOSS2_MSG, A1
    BRA SHOW_BOSS_MSG
SHOW_BOSS3:
    LEA BOSS3_MSG, A1
    BRA SHOW_BOSS_MSG
SHOW_BOSS4:
    LEA BOSS4_MSG, A1

SHOW_BOSS_MSG:
    MOVE.W #13, D0
    TRAP #15

    CLR.W   $4008          
    MOVE.B  #0, $4062
    MOVE.B  #0, SKIP_BOSS_TURN
    RTS

ALL_BOSSES_DEFEATED:
    LEA ALL_BOSSES_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    BRA END_GAME

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
* DATA SECTION
*-------------------------------------------------------
    ORG $3000

INPUT_BUFFER:   DS.B 16
CRLF:           DC.B $0D,$0A,0

INPUT_MSG:
    DC.B 'Choose your action:',$0D,$0A
    DC.B '1. Attack (10 dmg, -5 Energy)',$0D,$0A
    DC.B '2. Rifle (skip boss turn, -1 ammo)',$0D,$0A
    DC.B '3. Flee to elevator',$0D,$0A,0

PLAYER_STATS_HDR: DC.B 'PLAYER STATS:',0
PLAYER_HEALTH_MSG:      DC.B 'HEALTH: ',0
ENERGY_MSG:             DC.B 'ENERGY SWORD''S ENERGY: ',0
AMMO_MSG:               DC.B 'AMMO: ',0
ARTIFACTS_MSG:          DC.B 'ARTIFACTS: ',0
BOSS_HP_LABEL_MSG:      DC.B 'BOSS HP: ',0
WEATHER_LABEL_MSG:      DC.B 'WEATHER: ',0

WEATHER_RAIN_MSG: DC.B 'Rain',$0D,$0A,0
WEATHER_SUN_MSG:  DC.B 'Sun',$0D,$0A,0
WEATHER_FOG_MSG:  DC.B 'Fog',$0D,$0A,0
WEATHER_UNKNOWN_MSG: DC.B 'Unknown',$0D,$0A,0

GAMEPLAY_MSG: DC.B 'You approach the facility...',0
BOSS_SELECT_MSG: DC.B 'Choose boss to enter: 1=Glass Cannon, 2=Momentum, 3=Entropy, 4=Force',0
INVALID_BOSS_MSG: DC.B 'Invalid choice! Enter 1-4.',0
BOSS_DEAD_MSG:    DC.B 'That boss is already defeated. Choose another.',0
INVALID_ACTION_MSG: DC.B 'Invalid action! Choose 1-3.',0

BOSS1_MSG: DC.B 'Encountered Glass Cannon!',0
BOSS2_MSG: DC.B 'Encountered Momentum Thief!',0
BOSS3_MSG: DC.B 'Encountered Entropy Leech!',0
BOSS4_MSG: DC.B 'Encountered Force Inverter!',0

BOSS1_DEFEAT_MSG: DC.B 'Glass Cannon destroyed! Artifact A acquired.',$0D,$0A,0
BOSS2_DEFEAT_MSG: DC.B 'Momentum Thief neutralized! Artifact B acquired.',$0D,$0A,0
BOSS3_DEFEAT_MSG: DC.B 'Entropy Leech defeated! Artifact C acquired.',$0D,$0A,0
BOSS4_DEFEAT_MSG: DC.B 'Force Inverter down! Artifact D acquired.',$0D,$0A,0

HEALED_MSG: DC.B 'You are fully healed!',$0D,$0A,0
ENERGY_REPLENISHED_MSG: DC.B 'Energy Sword fully recharged!',$0D,$0A,0

CONTINUE_MSG:   DC.B 'PRESS ANYKEY TO CONTINUE: ',0
WIN_MSG:            DC.B 'MISSION COMPLETE! EXFIL SUCCESSFUL!',0
MISSION_FAILED_MSG: DC.B 'MISSION FAILED! YOU DIED.',0
NO_AMMO_MSG: DC.B 'No ammo left!',0
ALL_BOSSES_MSG: DC.B 'All bosses defeated.',$0D,$0A,0

WELCOME_MSG:
    DC.B '************************************************************',$0D,$0A
    DC.B 'WELCOME TO THE INFILTRATION MISSION!',$0D,$0A
    DC.B 'Collect 4 artifacts. Survive the physics anomalies.',$0D,$0A
    DC.B '************************************************************',$0D,$0A,0

    END START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~


