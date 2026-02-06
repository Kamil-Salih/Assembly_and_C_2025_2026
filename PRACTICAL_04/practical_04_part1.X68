*-----------------------------------------------------------
* Title      : practical_04_part1.X68
* Written by : Kamil Salih
* Date       : 06/02/2026
* Description: stores a health value in memory at address $3000 and then modifies it indirectly using an address register to simulate taking damage and picking up health.
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    ;   Move Health to Memory location $3000
    MOVE.B  #100, $3000
    
    ;   Load Memory Address $3000 into
    ;   Address Register A1
    LEA $3000, A1


    ;   Hit by NPC
    ;   Non Player Character
    SUB.B   #20, (A1)
    
    ;   Pickup Health Found
    ADD.B   #10, (A1)
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source
    
    
    ;Review questions, what do the address register mean and what is stored in memory and why?
    
    ;Address Register: Holds the memory address $3000, allowing indirect access to the data stored at that location.
    ;Memory: Stores the actual health value, which is updated from 100 to 80 and then to 90 so the value persists and can be modified across instructions.
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
