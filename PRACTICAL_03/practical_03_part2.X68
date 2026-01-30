*-----------------------------------------------------------
* Title      : practical_03_part2
* Written by : Kamil Salih
* Date       : 29/01/2026
* Description: Address register A2 holds the pointer to memory location $4000, where the program stores 100 and subtracts 10, resulting in the final value being 90
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    LEA     $4000,  A2  ; loads address $4000 into address register A2
    MOVE.B  #100,   (A2)    ; Stores byte value 100 (decimal) into memory at address stored in A2
    SUB.B   #10,    (A2)    ; Takes the currently stored byte at memory location (A2) and subtracts 10 from it
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

;Review questions, what do the address register mean and what is stored in memory and why?
;Address register: Address registers store memory addresses, not data. LEA $4000, A2 loads the address $4000 into A2. A2 is used to point to a memory location for data operations.
;Memory: Memory stores the actual data values. MOVE.B #100, (A2) stores 100 at memory address $4000. SUB.B #10, (A2) subtracts 10 from the value at that same memory location. Final value in memory at $4000 is 90.


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
