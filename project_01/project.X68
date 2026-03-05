*-----------------------------------------------------------
* Project Title: Alternative Physics: Facility Infiltration
* Student Name:  Kamil Salih
* Student ID:    C00307549
* Date:          05/03/2026
* Description:   
*-----------------------------------------------------------

    ORG $1000

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
* GAMELOOP
*-------------------------------------------------------
GAMELOOP:
    MOVE.B $4061, D0
    CMP.B #0, D0
    BEQ NO_BOSS_PROMPT

    LEA INPUT_MSG, A1
    MOVE.W #13, D0
    TRAP #15

    BSR GAMEPLAY
    BSR APPLY_BOSS_MECH    

    MOVE.B $4061, D0
    CMP.B #0, D0
    BEQ RTS_GAMELOOP_SKIP

    BSR UPDATE
    BSR STATS
    RTS

NO_BOSS_PROMPT:
    BSR SELECT_BOSS
    RTS

RTS_GAMELOOP_SKIP:
    RTS

*-------------------------------------------------------
* UPDATE (weather)
*-------------------------------------------------------
UPDATE:
    MOVE.B $4005, D0
    ADD.B #1, D0
    MOVE.B D0, $4005

    AND.B #1, D0
    BNE WEATHER_EVENT_SKIP

    BSR RANDOM_NUMBER
    MOVE.B D0, $4006

    CMP.B #0, $4006
    BEQ WEATHER_RAIN
    CMP.B #1, $4006
    BEQ WEATHER_SUN
    CMP.B #2, $4006
    BEQ WEATHER_FOG
    BRA WEATHER_EVENT_SKIP

WEATHER_RAIN:
    MOVE.B $4000, D0
    ADD.B #10, D0
    CMP.B #MAX_HEALTH, D0
    BLE RAIN_OK
    MOVE.B #MAX_HEALTH, D0
RAIN_OK:
    MOVE.B D0, $4000
    MOVE.B #0, $4004
    BRA WEATHER_EVENT_SKIP

WEATHER_SUN:
    MOVE.B $4001, D0
    ADD.B #40, D0            
    CMP.B #MAX_ENERGY, D0
    BLE SUN_OK
    MOVE.B #MAX_ENERGY, D0
SUN_OK:
    MOVE.B D0, $4001
    MOVE.B #0, $4004
    BRA WEATHER_EVENT_SKIP

WEATHER_FOG:
    MOVE.B #5, $4004
    BRA WEATHER_EVENT_SKIP

WEATHER_EVENT_SKIP:
    RTS

*-------------------------------------------------------
* STATS
*-------------------------------------------------------
STATS:
    LEA PLAYER_STATS_HDR, A1
    MOVE.W #13, D0
    TRAP #15

    LEA PLAYER_HEALTH_MSG, A1
    MOVE.W #14, D0        
    TRAP #15
    CLR.L D1
    MOVE.B $4000, D1
    MOVE.W #3, D0         
    TRAP #15
    BSR ENDL              

    LEA ENERGY_MSG, A1
    MOVE.W #14, D0
    TRAP #15
    CLR.L D1
    MOVE.B $4001, D1
    MOVE.W #3, D0
    TRAP #15
    BSR ENDL

    LEA AMMO_MSG, A1
    MOVE.W #14, D0
    TRAP #15
    CLR.L D1
    MOVE.B $4002, D1
    MOVE.W #3, D0
    TRAP #15
    BSR ENDL

    LEA ARTIFACTS_MSG, A1
    MOVE.W #14, D0
    TRAP #15
    CLR.L D1
    MOVE.B $4003, D1
    MOVE.W #3, D0
    TRAP #15
    BSR ENDL

    MOVE.B $4061, D0
    CMP.B #0, D0
    BEQ ST_WEATHER_LABEL    

    LEA BOSS_HP_LABEL_MSG, A1
    MOVE.W #14, D0
    TRAP #15

    MOVE.B $4061, D2
    CMP.B #1, D2
    BEQ ST_BOSS1_HP
    CMP.B #2, D2
    BEQ ST_BOSS2_HP
    CMP.B #3, D2
    BEQ ST_BOSS3_HP
    CMP.B #4, D2
    BEQ ST_BOSS4_HP
    BRA ST_BOSS_HP_DONE

ST_BOSS1_HP:
    CLR.L D1
    MOVE.W $4010, D1
    MOVE.W #3, D0
    TRAP #15
    BRA ST_BOSS_HP_DONE

ST_BOSS2_HP:
    CLR.L D1
    MOVE.W $4012, D1
    MOVE.W #3, D0
    TRAP #15
    BRA ST_BOSS_HP_DONE

ST_BOSS3_HP:
    CLR.L D1
    MOVE.W $4014, D1
    MOVE.W #3, D0
    TRAP #15
    BRA ST_BOSS_HP_DONE

ST_BOSS4_HP:
    CLR.L D1
    MOVE.W $4016, D1        
    MOVE.W #3, D0
    TRAP #15
    BRA ST_BOSS_HP_DONE

ST_BOSS_HP_DONE:
    BSR ENDL

ST_WEATHER_LABEL:
    LEA WEATHER_LABEL_MSG, A1
    MOVE.W #14, D0
    TRAP #15

    MOVE.B $4006, D0
    CMP.B #0, D0
    BEQ ST_WEATHER_RAIN
    CMP.B #1, D0
    BEQ ST_WEATHER_SUN
    CMP.B #2, D0
    BEQ ST_WEATHER_FOG
    BRA ST_WEATHER_UNKNOWN

ST_WEATHER_RAIN:
    LEA WEATHER_RAIN_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    RTS

ST_WEATHER_SUN:
    LEA WEATHER_SUN_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    RTS

ST_WEATHER_FOG:
    LEA WEATHER_FOG_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    RTS

ST_WEATHER_UNKNOWN:
    LEA WEATHER_UNKNOWN_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    RTS


*-------------------------------------------------------
* GAMEPLAY
*-------------------------------------------------------
GAMEPLAY:
    CLR.B PLAYER_ACTION

PLAYER_INPUT_LOOP:
    CLR.B INPUT_BUFFER
    MOVE.W #2, D0
    LEA INPUT_BUFFER, A1
    TRAP #15

    MOVE.B (INPUT_BUFFER), D1
    SUB.B #'0', D1

    CMP.B #1, D1
    BLT INVALID_ACTION
    CMP.B #3, D1
    BGT INVALID_ACTION

    MOVE.B D1, PLAYER_ACTION
    BRA PLAYER_ACTION_CHECK

INVALID_ACTION:
    LEA INVALID_ACTION_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    BRA PLAYER_INPUT_LOOP

PLAYER_ACTION_CHECK:
    CMP.B #1, PLAYER_ACTION
    BEQ PLAYER_ATTACK
    CMP.B #2, PLAYER_ACTION
    BEQ PLAYER_RIFLE
    CMP.B #3, PLAYER_ACTION
    BEQ PLAYER_FLEE
    BRA GP_RETURN

*-------------------------------------------------------
* PLAYER ATTACK
*-------------------------------------------------------
PLAYER_ATTACK:
    MOVE.B $4061, D2
    CMP.B #1, D2
    BEQ ATTACK_GC
    CMP.B #2, D2
    BEQ ATTACK_MT
    CMP.B #3, D2
    BEQ ATTACK_EL
    CMP.B #4, D2
    BEQ ATTACK_FI
    BRA GP_RETURN

ATTACK_GC: MOVE.W $4010, D0
    BRA APPLY_ATTACK
ATTACK_MT: MOVE.W $4012, D0
    BRA APPLY_ATTACK
ATTACK_EL: MOVE.W $4014, D0
    BRA APPLY_ATTACK
ATTACK_FI: MOVE.W $4016, D0
    BRA APPLY_ATTACK

*-------------------------------------------------------
* APPLY_ATTACK
*-------------------------------------------------------
APPLY_ATTACK:
    ; Check Energy First
    MOVE.B $4001, D3        
    CMP.B #0, D3
    BEQ ATTACK_NO_ENERGY

    ; Force Inverter Logic Check
    MOVE.B $4061, D2        ; Current Boss
    CMP.B #4, D2            ; Is it Force Inverter?
    BNE NORMAL_DMG_CALC
    
    MOVE.B $4006, D3        ; Current Weather
    CMP.B #2, D3            ; Is it Fog?
    BNE NORMAL_DMG_CALC
    MOVE.W #20, D1          ; Fog Inversion: Deal 20 Damage
    BRA APPLY_SUBTRACTION

NORMAL_DMG_CALC:
    MOVE.W #10, D1          ; Base Damage
    MOVE.B $4004, D2        ; Fog Penalty
    EXT.W D2
    SUB.W D2, D1            ; Reduce damage by fog penalty
    CMP.W #0, D1
    BGE APPLY_SUBTRACTION
    MOVE.W #0, D1

APPLY_SUBTRACTION:
    SUB.W D1, D0            ; Subtract damage from boss HP
    TST.W D0
    BMI SET_HP_ZERO         
    BRA STORE_HP

SET_HP_ZERO:
    MOVE.W #0, D0

STORE_HP:
    MOVE.B $4061, D2
    CMP.B #1, D2
    BEQ ST_GC
    CMP.B #2, D2
    BEQ ST_MT
    CMP.B #3, D2
    BEQ ST_EL
    CMP.B #4, D2
    BEQ ST_FI
    BRA POST_ATTACK

ST_GC: MOVE.W D0, $4010
    BRA POST_ATTACK
ST_MT: MOVE.W D0, $4012
    BRA POST_ATTACK
ST_EL: MOVE.W D0, $4014
    BRA POST_ATTACK
ST_FI: MOVE.W D0, $4016

POST_ATTACK:
    MOVE.B $4001, D0        ; Reduce Energy
    SUB.B #5, D0
    CMP.B #0, D0
    BGE OK_EN
    MOVE.B #0, D0
OK_EN:
    MOVE.B D0, $4001
    MOVE.B D1, $4062        ; Store for Momentum Thief
    BRA GP_RETURN

ATTACK_NO_ENERGY:
    MOVE.W #0, D1           ; No energy = 0 damage
    BRA APPLY_SUBTRACTION

*-------------------------------------------------------
* PLAYER RIFLE
*-------------------------------------------------------
PLAYER_RIFLE:
    MOVE.B $4002, D0        
    CMP.B #0, D0
    BEQ NO_AMMO             

    SUB.B #1, D0            
    MOVE.B D0, $4002        

    MOVE.B #2, SKIP_BOSS_TURN  
    BRA GP_RETURN

NO_AMMO:
    MOVE.B #0, SKIP_BOSS_TURN 
    LEA NO_AMMO_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    BRA GP_RETURN

*-------------------------------------------------------
* PLAYER FLEE
*-------------------------------------------------------
PLAYER_FLEE:
    MOVE.B #0, $4004
    MOVE.B #0, $4005
    MOVE.B #0, $4006
    MOVE.B #0, $4061
    CLR.W   $4008
    MOVE.B #0, $4062
    MOVE.B #0, SKIP_BOSS_TURN
    BRA GP_RETURN

GP_RETURN:
    RTS

*-------------------------------------------------------
* BOSS TURN LOGIC
*-------------------------------------------------------
APPLY_BOSS_MECH:
    MOVE.B $4001, $4064     ; Save energy for Entropy check

    MOVE.B SKIP_BOSS_TURN, D7
    CMP.B #0, D7
    BEQ CONT_BOSS_CHECK
    SUB.B #1, D7
    MOVE.B D7, SKIP_BOSS_TURN
    BRA BOSS_END

CONT_BOSS_CHECK:
    MOVE.B $4061, D0
    CMP.B #1, D0
    BEQ BOSS_GC
    CMP.B #2, D0
    BEQ BOSS_MT
    CMP.B #3, D0
    BEQ BOSS_EL
    CMP.B #4, D0
    BEQ BOSS_FI
    BRA BOSS_END

BOSS_GC:
    MOVE.W $4010, D1
    CMP.W #0, D1
    BNE GC_ACT
    MOVE.B BOSS1_DEAD, D2
    CMP.B #1, D2
    BEQ BOSS_END
    MOVE.B #1, BOSS1_DEAD
    MOVE.B $4003, D0
    ADD.B #1, D0
    MOVE.B D0, $4003
    LEA BOSS1_DEFEAT_MSG, A1
    BSR DEFEAT_RESTORE
    BRA BOSS_END
GC_ACT:
    MOVE.B $4000, D0
    SUB.B #20, D0
    BRA BOSS_DMG_LIMIT

BOSS_MT:
    MOVE.W $4012, D1
    CMP.W #0, D1
    BNE MT_ACT
    MOVE.B BOSS2_DEAD, D3
    CMP.B #1, D3
    BEQ BOSS_END
    MOVE.B #1, BOSS2_DEAD
    MOVE.B $4003, D3
    ADD.B #1, D3
    MOVE.B D3, $4003
    LEA BOSS2_DEFEAT_MSG, A1
    BSR DEFEAT_RESTORE
    BRA BOSS_END
MT_ACT:
    CLR.W D0
    MOVE.W $4008, D0
    ADD.W #2, D0
    MOVE.B $4000, D1
    SUB.B D0, D1
    MOVE.B D1, $4000
    CLR.W $4008
    CLR.L D0
    MOVE.B $4062, D0
    MOVE.W D0, $4008
    BRA BOSS_END

BOSS_EL:
    MOVE.W $4014, D1
    CMP.W #0, D1
    BNE EL_ACT
    MOVE.B BOSS3_DEAD, D2
    CMP.B #1, D2
    BEQ BOSS_END
    MOVE.B #1, BOSS3_DEAD
    MOVE.B $4003, D2
    ADD.B #1, D2
    MOVE.B D2, $4003
    LEA BOSS3_DEFEAT_MSG, A1
    BSR DEFEAT_RESTORE
    BRA BOSS_END
EL_ACT:
    MOVE.B $4064, D2        
    MOVE.B $4001, D0        
    SUB.B #10, D0
    CMP.B #0, D0
    BGE OK_EL
    MOVE.B #0, D0
OK_EL:
    MOVE.B D0, $4001
    CMP.B #0, D2            
    BEQ SKIP_EL_HEAL
    CMP.B #0, D0            
    BNE SKIP_EL_HEAL
    MOVE.W $4014, D0
    ADD.W #10, D0
    MOVE.W D0, $4014
SKIP_EL_HEAL:
    MOVE.B $4000, D3
    SUB.B #5, D3
    MOVE.B D3, $4000
    BRA BOSS_END

BOSS_FI:
    MOVE.W $4016, D1
    CMP.W #0, D1
    BNE FI_ACT
    MOVE.B BOSS4_DEAD, D2
    CMP.B #1, D2
    BEQ BOSS_END
    MOVE.B #1, BOSS4_DEAD
    MOVE.B $4003, D2
    ADD.B #1, D2
    MOVE.B D2, $4003
    LEA BOSS4_DEFEAT_MSG, A1
    BSR DEFEAT_RESTORE
    BRA BOSS_END
FI_ACT:
    MOVE.B $4000, D2
    SUB.B #5, D2            ; Force deals flat 5 damage
    MOVE.B D2, $4000
    BRA BOSS_END

BOSS_DMG_LIMIT:
    CMP.B #0, D0
    BGE OK_LIMIT
    MOVE.B #0, D0
OK_LIMIT:
    MOVE.B D0, $4000
    BRA BOSS_END

DEFEAT_RESTORE:
    MOVE.W #13, D0
    TRAP #15
    MOVE.B #MAX_HEALTH, $4000
    LEA HEALED_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    MOVE.B #MAX_ENERGY, $4001
    LEA ENERGY_REPLENISHED_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    MOVE.B #0, $4061
    CLR.W $4008
    MOVE.B #0, SKIP_BOSS_TURN
    BSR SELECT_BOSS
    RTS

BOSS_END:
    MOVE.B $4000, D0
    CMP.B #0, D0
    BGT BOSS_RET
    LEA MISSION_FAILED_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    SIMHALT
BOSS_RET:
    RTS

*-------------------------------------------------------
* UTILITIES
*-------------------------------------------------------
CONTINUE:
    LEA CONTINUE_MSG, A1
    MOVE.W #13, D0
    TRAP #15
    MOVE.W #5, D0
    TRAP #15
    RTS

ENDL:
    LEA CRLF, A1
    MOVE.W #13, D0
    TRAP #15
    RTS

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
