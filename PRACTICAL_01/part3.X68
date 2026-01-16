*-----------------------------------------------------------
* Title      : part3.X68
* Written by : Kamil Salih
* Date       : 16/01/2026
* Description: Practical 1
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    MOVE.B #$64, D1         ; Load immediate value (100 in decimal) into D1
    LEA text, A1            ; Load immediate address of text into A1
    MOVE #14, D0            ; Load immediate value (14) into D0
    TRAP #15                ; Execute TRAP (Output D0 to console)
    
    MOVE #3, D0             ; Load immediate value (3) into D0
    TRAP #15                ; Execute TRAP (Output D0 to console)

    SIMHALT             ; halt simulator


text:   dc.b 'Data Register: ', 0   ; Define the string 'Data Register:'

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
