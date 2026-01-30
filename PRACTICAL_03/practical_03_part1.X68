*-----------------------------------------------------------
* Title      : practical_03_part1
* Written by : Kamil Salih
* Date       : 29/01/2026
* Description: loads address $4000 into address register A1 and stores byte value 100 into memory location pointed to by A1
*-----------------------------------------------------------
    ORG    $1000        ; starting address of the program is set to $1000
START:                  ; first instruction of program

* Put program code here

    LEA $4000,  A1      ; address $4000 is loaded into address register A1
    MOVE.B      #100,   (A1)    ; a byte that contains decimal value 100  is stored at memory address $4000

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

;Review questions, what does the address register mean and what is stored in memory and why?
;Address register: Stores a memory address, not data. LEA $4000, A1 loads $4000 into A1. A1 is used to point to where data is stored in memory.
;Memory: Stores the actual data value. MOVE.B #100, (A1) stores 100 at memory address $4000. Only one byte is stored because MOVE.B is used.


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
