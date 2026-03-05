*-----------------------------------------------------------
* Project Title: Alternative Physics: Facility Infiltration
* Student Name:  Kamil Salih
* Student ID:    C00307549
* Date:          05/03/2026
* Description:   You are a mercenary infiltrating a mysterious facility, battling physics-defying bosses to collect four artifacts and escape—or face death.
*-----------------------------------------------------------

    ORG $1000    ; Set program origin (starting memory address) to $1000

*-------------------------------------------------------
* CONSTANTS
*-------------------------------------------------------
EXIT            EQU 0    ; Constant representing exit/termination value
MAX_HEALTH      EQU 100  ; Maximum player health value
MAX_ENERGY      EQU 100  ; Maximum player energy value
MAX_AMMO        EQU 5    ; Maximum amount of ammo the player can hold
NUM_ARTIFACTS   EQU 4    ; Total number of artifacts in the game

GLASS_CANNON_HEALTH   EQU 50    ; Health value for the Glass Cannon boss
MOMENTUM_THIEF_HEALTH EQU 100    ; Health value for the Momentum Thief boss
ENTROPY_LEECH_HEALTH  EQU 100    ; Health value for the Entropy Leech boss
FORCE_INVERTER_HEALTH EQU 150    ; Health value for the Force Inverter boss

PLAYER_ACTION   EQU $4070        ; Memory address storing the player's selected action
SKIP_BOSS_TURN  EQU $4063        ; Memory flag used to indicate the boss should skip its turn

BOSS1_DEAD      EQU $4020        ; Memory flag indicating if boss 1 has been defeated
BOSS2_DEAD      EQU $4021        ; Memory flag indicating if boss 2 has been defeated
BOSS3_DEAD      EQU $4022        ; Memory flag indicating if boss 3 has been defeated
BOSS4_DEAD      EQU $4023        ; Memory flag indicating if boss 4 has been defeated

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

    ; Boss HP (words). Here, we initialise each boss's health. MOVE.W is used in case the game is ever expanded to be more complex (more moves, healing, longer battles, etc)
    MOVE.W  #GLASS_CANNON_HEALTH,   $4010    
    MOVE.W  #MOMENTUM_THIEF_HEALTH, $4012
    MOVE.W  #ENTROPY_LEECH_HEALTH,  $4014
    MOVE.W  #FORCE_INVERTER_HEALTH, $4016

    ; Boss defeated flags, they are cleared for each boss
    MOVE.B  #0, BOSS1_DEAD
    MOVE.B  #0, BOSS2_DEAD
    MOVE.B  #0, BOSS3_DEAD
    MOVE.B  #0, BOSS4_DEAD
    RTS

*-------------------------------------------------------
* START
*-------------------------------------------------------
START:              
    BSR RESET_GAME    ; Branch to subroutine to reset all game variables/state
    BSR WELCOME        ; Branch to subroutine that displays the welcome message

    ; print "You approach the facility..." once
    LEA GAMEPLAY_MSG, A1    ; Load effective address of GAMEPLAY_MSG string into address register A1
    MOVE.W #13, D0          ; Load trap task code 13 (print string) into D0
    TRAP #15                ; Call system trap to print the string pointed to by A1
    BSR CONTINUE            ; Branch to subroutine that waits for player to continue

    BSR SELECT_BOSS_IF_NONE    ; Ensure the player selects a boss if the player is not fighting one
    BSR GAME                   ; Branch to the main game loop/subroutine
    SIMHALT                    ; Stop the simulator when the game ends
    RTS                        ; Return from subroutine (safety return if reached just in case)

*-------------------------------------------------------
* CHECK WIN
*-------------------------------------------------------
CHECK_WIN:
    MOVE.B $4003, D0            ; Load the number of collected artifacts (stored at $4003) into D0
    CMP.B #NUM_ARTIFACTS, D0    ; Compare collected artifacts with the total required (NUM_ARTIFACTS)
    BEQ WIN_TRUE                ; If equal, branch to WIN_TRUE (player has collected all artifacts)
    MOVE.B #0, D0               ; Otherwise set D0 to 0 (win condition not met)
    RTS                         ; Return from subroutine

WIN_TRUE:
    MOVE.B #1, D0                ; Set D0 to 1 to indicate the win condition is true
    RTS                          ; Return from subroutine

*-------------------------------------------------------
* GAME
*-------------------------------------------------------
GAME:
MAIN_LOOP:
    BSR CHECK_WIN    ; Call subroutine to check if the player has won
    CMP.B #1, D0     ; Compares the result in D0 with 1 (win condition true)
    BEQ END_GAME     ; If it is equal, branch to END_GAME

    BSR GAMELOOP     ; Otherwise, execute one iteration of the main game loop
    BRA MAIN_LOOP    ; The loop is repeated indefinitely until the win condition is met

END_GAME:
    LEA WIN_MSG, A1    ; Load address of the win message string into A1
    MOVE.W #13, D0     ; Load trap code 13 (prints the string contained in WIN_MSG)
    TRAP #15           ; The system call to print the win message
    SIMHALT            ; Halts the simulator (game is finished)
    RTS                ; Return from subroutine (safety return just in case)

*-------------------------------------------------------
* WELCOME (only at start)
*-------------------------------------------------------
WELCOME:                    ; Load address of the welcome message string into A1
    LEA WELCOME_MSG, A1     ; Load trap code 13 (print string) into D0
    MOVE.W #13, D0          ; System call to print the welcome message
    TRAP #15                ; Call subroutine to wait for player input to continue
    BSR CONTINUE            ; Return from subroutine
    RTS

*-------------------------------------------------------
* RANDOM NUMBER (0–2)
*-------------------------------------------------------
RANDOM_NUMBER:
    MOVE.W #8, D0        ; Load trap task 8 (generate random number) into D0
    TRAP #15             ; Call system trap to generate random value (returned in D1)
    MOVE.W D1, D0        ; Copy generated random value from D1 into D0
    ANDI.W #3, D0        ; Mask value with 3 to limit result to range 0–3
    CMP.W #3, D0         ; Compare result with 3
    BNE RN_OK            ; If result is not 3, branch to RN_OK
    MOVE.W #2, D0        ; If result was 3, change it to 2 to keep range 0–2
RN_OK:
    RTS                  ; Return with random number (0–2) in D0

*-------------------------------------------------------
* SELECT_BOSS_IF_NONE (with validation 1–4)
*-------------------------------------------------------
SELECT_BOSS_IF_NONE:
    MOVE.B $4061, D0    ; Load current boss selection from memory address $4061 into D0
    CMP.B #1, D0        ; Compare selected boss value with 1 (minimum valid boss)
    BLT SB_NEED_SELECT  ; If value is less than 1, branch to request boss selection
    CMP.B #4, D0        ; Compare selected boss value with 4 (maximum valid boss)
    BGT SB_NEED_SELECT  ; If value is greater than 4, branch to request boss selection
    RTS                 ; Otherwise boss selection is valid, return

SB_NEED_SELECT:
    BSR SELECT_BOSS     ; Call subroutine to prompt player to choose a boss
    RTS                 ; Return after boss selection

*-------------------------------------------------------
* BOSS INPUT LOOP
*-------------------------------------------------------
BOSS_INPUT_LOOP:
    CLR.B INPUT_BUFFER            ; Clear the input buffer byte before reading new input
    MOVE.W #2, D0                 ; Load trap task 2 (read character/string input)
    LEA INPUT_BUFFER, A1          ; Load address of INPUT_BUFFER into A1 for input storage
    TRAP #15                      ; Call system trap to read user input

    MOVE.B (INPUT_BUFFER), D1     ; Move the first character from the input buffer into D1
    SUB.B #'0', D1                ; Convert ASCII digit to numeric value by subtracting '0'

    CMP.B #1, D1                  ; Compare input with 1 (minimum valid boss number)
    BLT INVALID_BOSS_INPUT        ; If input < 1, branch to invalid input handler code
    CMP.B #4, D1                  ; Compare input with 4 (maximum valid boss number)
    BGT INVALID_BOSS_INPUT        ; If input > 4, branch to invalid input handler code

    CMP.B #1, D1                  ; Check if player selected boss 1
    BEQ CHK_B1                    ; If yes, branch to boss 1 validation
    CMP.B #2, D1                  ; Check if player selected boss 2
    BEQ CHK_B2                    ; If yes, branch to boss 2 validation
    CMP.B #3, D1                  ; Check if player selected boss 3
    BEQ CHK_B3                    ; If yes, branch to boss 3 validation
    CMP.B #4, D1                  ; Check if player selected boss 4
    BEQ CHK_B4                    ; If yes, branch to boss 4 validation

CHK_B1:
    MOVE.B BOSS1_DEAD, D2         ; Load boss 1 defeated flag into D2
    CMP.B #1, D2                  ; Check if boss 1 is already defeated
    BEQ BOSS_ALREADY_DEAD         ; If defeated, inform player and re-prompt
    BRA BOSS_OK                   ; Otherwise boss selection is valid

CHK_B2:
    MOVE.B BOSS2_DEAD, D2         ; Load boss 2 defeated flag into D2
    CMP.B #1, D2                  ; Check if boss 2 is already defeated
    BEQ BOSS_ALREADY_DEAD         ; If defeated, inform player and re-prompt
    BRA BOSS_OK                   ; Otherwise boss selection is valid

CHK_B3:
    MOVE.B BOSS3_DEAD, D2         ; Load boss 3 defeated flag into D2
    CMP.B #1, D2                  ; Check if boss 3 is already defeated
    BEQ BOSS_ALREADY_DEAD         ; If defeated, inform player and re-prompt
    BRA BOSS_OK                   ; Otherwise boss selection is valid

CHK_B4:
    MOVE.B BOSS4_DEAD, D2         ; Load boss 4 defeated flag into D2
    CMP.B #1, D2                  ; Check if boss 4 is already defeated
    BEQ BOSS_ALREADY_DEAD         ; If defeated, inform player and re-prompt
    BRA BOSS_OK                   ; Otherwise boss selection is valid

BOSS_ALREADY_DEAD:
    LEA BOSS_DEAD_MSG, A1         ; Load address of message indicating boss is already defeated
    MOVE.W #13, D0                ; Load trap code 13 (print string)
    TRAP #15                      ; Display the message
    BRA BOSS_INPUT_LOOP           ; Loop back to prompt player for another boss selection

BOSS_OK:
    MOVE.B D1, $4061               ; Store the valid selected boss number into memory $4061
    RTS                            ; Return from subroutine

INVALID_BOSS_INPUT:
    LEA INVALID_BOSS_MSG, A1       ; Load address of invalid input message
    MOVE.W #13, D0                 ; Load trap code 13 (print string)
    TRAP #15                       ; Display the invalid input message
    BRA BOSS_INPUT_LOOP            ; Loop back to prompt player again

*-------------------------------------------------------
* SELECT BOSS
*-------------------------------------------------------
SELECT_BOSS:
    BSR CHECK_WIN                ; Call subroutine to check if all bosses/artifacts are completed
    CMP.B #1, D0                 ; Compare result with 1 (win condition)
    BEQ ALL_BOSSES_DEFEATED      ; If win condition true, branch to message that all bosses are defeated

    LEA BOSS_SELECT_MSG, A1      ; Load address of boss selection prompt message into A1
    MOVE.W #13, D0               ; Load trap code 13 (print string)
    TRAP #15                     ; Display boss selection message

    BSR BOSS_INPUT_LOOP          ; Call loop that handles boss input and validation

    MOVE.B $4061, D0             ; Load selected boss number from memory into D0
    CMP.B #1, D0                 ; Check if boss 1 was selected
    BEQ SHOW_BOSS1               ; Branch to show boss 1 intro message
    CMP.B #2, D0
    BEQ SHOW_BOSS2
    CMP.B #3, D0
    BEQ SHOW_BOSS3
    CMP.B #4, D0
    BEQ SHOW_BOSS4
    RTS                          ; Return if none matched (safety return)

SHOW_BOSS1:
    LEA BOSS1_MSG, A1            ; Load address of boss 1 introduction message
    BRA SHOW_BOSS_MSG            ; Jump to common boss message display
SHOW_BOSS2:
    LEA BOSS2_MSG, A1
    BRA SHOW_BOSS_MSG
SHOW_BOSS3:
    LEA BOSS3_MSG, A1
    BRA SHOW_BOSS_MSG
SHOW_BOSS4:
    LEA BOSS4_MSG, A1

SHOW_BOSS_MSG:
    MOVE.W #13, D0               ; Load trap code 13 (print string)
    TRAP #15                     ; Display the selected boss message

    CLR.W   $4008                ; Clear stored momentum damage for boss mechanics
    MOVE.B  #0, $4062            ; Reset last player damage value
    MOVE.B  #0, SKIP_BOSS_TURN   ; Reset rifle skip-turn counter
    RTS

ALL_BOSSES_DEFEATED:
    LEA ALL_BOSSES_MSG, A1        ; Load address of message indicating all bosses are defeated
    MOVE.W #13, D0
    TRAP #15
    BRA END_GAME                  ; Jump to game ending routine

*-------------------------------------------------------
* GAMELOOP
*-------------------------------------------------------
GAMELOOP:
    MOVE.B $4061, D0            ; Load current boss selection into D0
    CMP.B #0, D0                ; Check if no boss is currently selected
    BEQ NO_BOSS_PROMPT          ; If 0, branch to prompt player to select a boss

    LEA INPUT_MSG, A1            ; Load address of gameplay input prompt message
    MOVE.W #13, D0
    TRAP #15

    BSR GAMEPLAY                  ; Call subroutine that handles player gameplay action
    BSR APPLY_BOSS_MECH           ; Apply the current boss's special mechanics
        
    MOVE.B $4061, D0              ; Reload boss selection to check if boss was cleared/defeated
    CMP.B #0, D0                  ; Check if boss value is now 0
    BEQ RTS_GAMELOOP_SKIP         ; If so, skip and return

    BSR UPDATE
    BSR STATS                     ; Display updated player/boss statistics
    RTS

NO_BOSS_PROMPT:
    BSR SELECT_BOSS                ; No boss selected, so prompt the player to choose one
    RTS                            ; Return after boss selection

RTS_GAMELOOP_SKIP:
    RTS                            ; Return without running update/stats

*-------------------------------------------------------
* UPDATE (weather)
*-------------------------------------------------------
UPDATE:
    MOVE.B $4005, D0        ; Load current turn counter into D0
    ADD.B #1, D0            ; Increment turn counter by 1
    MOVE.B D0, $4005        ; Store updated turn counter back to memory

    AND.B #1, D0              ; Check if turn number is odd/even (mask lowest bit)
    BNE WEATHER_EVENT_SKIP    ; If odd turn, skip weather event

    BSR RANDOM_NUMBER        ; Generate random number (0–2) for weather type
    MOVE.B D0, $4006         ; Store weather type in memory

    CMP.B #0, $4006            ; Check if weather type is rain
    BEQ WEATHER_RAIN           ; If rain, branch to rain effect
    CMP.B #1, $4006            ; Check if weather type is sun
    BEQ WEATHER_SUN            ; If sun, branch to sun effect
    CMP.B #2, $4006            ; Check if weather type is fog
    BEQ WEATHER_FOG            ; If fog, branch to fog effect
    BRA WEATHER_EVENT_SKIP     ; Otherwise skip weather effects

WEATHER_RAIN:
    MOVE.B $4000, D0            ; Load player health
    ADD.B #10, D0                ; Increase health by 10 due to rain effect
    CMP.B #MAX_HEALTH, D0        ; Compare with maximum allowed health
    BLE RAIN_OK                    ; If within limit, keep value
    MOVE.B #MAX_HEALTH, D0        ; Otherwise cap health at MAX_HEALTH
RAIN_OK:
    MOVE.B D0, $4000            ; Store updated health back to memory
    MOVE.B #0, $4004            ; Clear fog penalty
    BRA WEATHER_EVENT_SKIP        ; Exit weather processing

WEATHER_SUN:
    MOVE.B $4001, D0            ; Load player energy
    ADD.B #40, D0                ; Increase energy by 40 due to sunlight
    CMP.B #MAX_ENERGY, D0        ; Compare with maximum allowed energy
    BLE SUN_OK                    ; If within limit, keep value
    MOVE.B #MAX_ENERGY, D0        ; Otherwise cap energy at MAX_ENERGY
SUN_OK:
    MOVE.B D0, $4001                ; Store updated energy back to memory
    MOVE.B #0, $4004                ; Clear fog penalty
    BRA WEATHER_EVENT_SKIP          ; Exit weather processing

WEATHER_FOG:
    MOVE.B #5, $4004            ; Apply fog penalty of 5 damage reduction
    BRA WEATHER_EVENT_SKIP         ; Exit weather processing

WEATHER_EVENT_SKIP:
    RTS

*-------------------------------------------------------
* STATS
*-------------------------------------------------------
STATS:
    LEA PLAYER_STATS_HDR, A1    ; Load address of player stats header message
    MOVE.W #13, D0               ; Trap code to print string
    TRAP #15                    ; Display header

    LEA PLAYER_HEALTH_MSG, A1    ; Load "Player Health" label
    MOVE.W #14, D0                ; Trap code to print label without newline
    TRAP #15
    CLR.L D1                    ; Clear D1 before loading value
    MOVE.B $4000, D1            ; Load player health into D1
    MOVE.W #3, D0                 ; Trap code to print number
    TRAP #15
    BSR ENDL                  ; Print newline

    LEA ENERGY_MSG, A1        ; Load "Energy" label
    MOVE.W #14, D0
    TRAP #15
    CLR.L D1
    MOVE.B $4001, D1            ; Load player energy value
    MOVE.W #3, D0
    TRAP #15
    BSR ENDL

    LEA AMMO_MSG, A1        ; Load "Ammo" label
    MOVE.W #14, D0
    TRAP #15
    CLR.L D1
    MOVE.B $4002, D1        ; Load ammo count
    MOVE.W #3, D0
    TRAP #15
    BSR ENDL

    LEA ARTIFACTS_MSG, A1    ; Load "Artifacts" label
    MOVE.W #14, D0
    TRAP #15
    CLR.L D1
    MOVE.B $4003, D1          ; Load artifact count
    MOVE.W #3, D0
    TRAP #15
    BSR ENDL

    MOVE.B $4061, D0        ; Load current boss selection
    CMP.B #0, D0            ; Check if a boss is active
    BEQ ST_WEATHER_LABEL    ; If no boss, skip boss HP display

    LEA BOSS_HP_LABEL_MSG, A1    ; Load "Boss HP" label
    MOVE.W #14, D0
    TRAP #15

    MOVE.B $4061, D2        ; Copy boss ID into D2
    CMP.B #1, D2            ; Check if boss 1
    BEQ ST_BOSS1_HP
    CMP.B #2, D2            ; Check if boss 2
    BEQ ST_BOSS2_HP
    CMP.B #3, D2            ; Check if boss 3
    BEQ ST_BOSS3_HP
    CMP.B #4, D2            ; Check if boss 4
    BEQ ST_BOSS4_HP
    BRA ST_BOSS_HP_DONE     ; If none matched, skip

ST_BOSS1_HP:
    CLR.L D1                ; Clear D1
    MOVE.W $4010, D1        ; Load boss 1 HP
    MOVE.W #3, D0            ; Print number
    TRAP #15
    BRA ST_BOSS_HP_DONE

ST_BOSS2_HP:
    CLR.L D1
    MOVE.W $4012, D1        ; Load boss 2 HP
    MOVE.W #3, D0
    TRAP #15
    BRA ST_BOSS_HP_DONE

ST_BOSS3_HP:
    CLR.L D1
    MOVE.W $4014, D1        ; Load boss 3 HP
    MOVE.W #3, D0
    TRAP #15
    BRA ST_BOSS_HP_DONE

ST_BOSS4_HP:
    CLR.L D1
    MOVE.W $4016, D1         ; Load boss 4 HP
    MOVE.W #3, D0
    TRAP #15
    BRA ST_BOSS_HP_DONE

ST_BOSS_HP_DONE:
    BSR ENDL        ; Print newline after boss HP

ST_WEATHER_LABEL:
    LEA WEATHER_LABEL_MSG, A1        ; Load "Weather" label
    MOVE.W #14, D0
    TRAP #15

    MOVE.B $4006, D0        ; Load current weather type
    CMP.B #0, D0            ; Check if rain
    BEQ ST_WEATHER_RAIN
    CMP.B #1, D0            ; Check if sun
    BEQ ST_WEATHER_SUN
    CMP.B #2, D0            ; Check if fog
    BEQ ST_WEATHER_FOG
    BRA ST_WEATHER_UNKNOWN    ; If unknown value

ST_WEATHER_RAIN:
    LEA WEATHER_RAIN_MSG, A1    ; Load rain message
    MOVE.W #13, D0
    TRAP #15                    ; Display weather message
    RTS

ST_WEATHER_SUN:
    LEA WEATHER_SUN_MSG, A1    ; Load sun message
    MOVE.W #13, D0
    TRAP #15   
    RTS

ST_WEATHER_FOG:
    LEA WEATHER_FOG_MSG, A1    ; Load fog message
    MOVE.W #13, D0
    TRAP #15
    RTS

ST_WEATHER_UNKNOWN:
    LEA WEATHER_UNKNOWN_MSG, A1        ; Load unknown weather message
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





