*-----------------------------------------------------------
* Title      : practical_06_part3
* Written by : Kamil Salih
* Date       : 27/02/2026
* Description: The program initializes the stack pointer to address $4000, pushes the byte values 1 through 4 onto the stack using pre-decrement addressing, and then pops them back into register D1 using post-increment addressing.
*-----------------------------------------------------------
ORG $1000

START:
    LEA $4000, A7

    MOVE.B #1, -(A7)
    MOVE.B #2, -(A7)
    MOVE.B #3, -(A7)
    MOVE.B #4, -(A7)

    MOVE.B (A7)+, D1
    MOVE.B (A7)+, D1
    MOVE.B (A7)+, D1
    MOVE.B (A7)+, D1

END:

;Review questions, what is the purpose of Address Register A7?
;Address Register A7: It acts as the stack pointer, storing the address of the top of the stack and automatically updating during push (pre-decrement) and pop (post-increment) operations.
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
