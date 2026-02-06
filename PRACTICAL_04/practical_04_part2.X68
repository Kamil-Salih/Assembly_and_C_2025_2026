*-----------------------------------------------------------
* Title      : practical_04_part2
* Written by : Kamil Salih
* Date       : 06/02/2026
* Description: This 68K program uses data registers and logic operations to process values, then uses an address register to indirectly update a player’s health value stored in memory to simulate damage and recovery.
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    ; Move Health to Memory Location $3000
    MOVE.B  #100, $3000
    
    ; Move Location of Player into Data Register
    ; X first Byte 0 to 15
    ; Y second Byte 0 to 15
    MOVE.B  #$12, D2
    
    ; Move Location of NPC into Data Register
    ; X first Byte 0 to 15
    ; Y first Byte 0 to 15
    
    ; Bitwise AND D2 and D3
    ; What's new location of Player
    AND.B   D2, D3
    
    ; Load Memory Address $3000 into
    ; Address Register A1
    LEA $3000, A1
    
    ; Hit by NPC
    ; Non Player Character
    SUB.B   #20, (A1)
    
    ; Pickup Health Found
    ADD.B   #10, (A1)

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


    ;Review questions, what do the logic instructions mean, what Addressing Modes are used?
    ;Address register: Stores the memory address $3000 (via LEA $3000, A1) so the program can indirectly modify the player’s health value in memory.
    ;Memory: Stores the player’s health value at $3000, which is changed during execution (initialised to 100, reduced by damage, then increased by health pickup) so the value persists across instructions.
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
