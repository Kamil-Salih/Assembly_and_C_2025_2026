*-----------------------------------------------------------
* Title      : practical_03_part3
* Written by : Kamil Salih
* Date       : 29/01/2026
* Description: HEALTH dc.b $64 declares a byte in memory labelled HEALTH and initializes it with the value $64 (which is 100 in decimal).
*               The instruction LEA HEALTH, A3 loads the address of that byte into A3 so that SUB.B #10,(A3) subtracts 10 from the stored value, leaving 90 in the memory location labelled HEALTH.
*-----------------------------------------------------------
    ORG    $1000        ; Sets the starting address of the program in memory to $1000
START:                  ; first instruction of program

* Put program code here

    LEA HEALTH,     A3      ; Loads the address of the memory location labelled HEALTH into address register A3 (so A3 points to HEALTH)
    SUB.B   #10,    (A3)    ; Subtracts the byte value 10 from the byte stored at the memory address pointed to by A3, and writes the result back to that same memory location
    

    SIMHALT             ; halt simulator

* Put variables and constants here

HEALTH  dc.b    $64     ; Reserves one byte of memory labelled HEALTH and initializes it with $64

    END    START        ; last line of source


; Review questions, what does the Health declaration mean and what is stored in memory and why?
;Health: HEALTH is a label that represents a memory location. dc.b means define constant byte. $64 initializes that memory location with the value 100 (decimal).
;Memory: The memory location labeled HEALTH initially stores 100. SUB.B #10, (A3) subtracts 10 from this value. After execution, the value stored at HEALTH is 90.
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
