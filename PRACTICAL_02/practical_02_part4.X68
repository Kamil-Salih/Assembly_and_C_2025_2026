*-----------------------------------------------------------
* Title      : practical_02_part4
* Written by : Kamil Salih
* Date       : 22/01/2026
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  

    *moving to data registers
    
    MOVE.B  #1, D0
    MOVE.W  #15, D1
    MOVE.L  #25, D2
    MOVE.B  #$AB,   D3
    MOVE.W  #$ABC, D4
    MOVE.L  #$ABCDEF, D5
    MOVE.L  #%10101010, D6
    
    *moving data to memory
    
    MOVE.B  #%11110000, $3000
    MOVE.W  #$EEEE, $3002
    MOVE.B  D0, $3004
    MOVE.W  D1, $3006
    MOVE.L  #66666, $3008
    MOVE.L  D2, $3010
    
    
    *moving from memory to registers
    
    MOVE.B $3000,   D0
    MOVE.W $3002,   D1
    MOVE.L $3008,   D2
    MOVE.B #$AB, D3
    MOVE.W #$ABC,    D4
    
    SIMHALT             


    END    START       
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
