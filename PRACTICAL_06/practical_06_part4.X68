*-----------------------------------------------------------
* Title      : practical_06_part4
* Written by : Kamil Salih
* Date       : 27/02/2026
* Description: This program initializes the stack pointer, pushes the byte values 1 through 4 onto the stack, and then pops them back into register D1 in last-in, first-out (LIFO) order.
*-----------------------------------------------------------
ORG $1000

START:
    LEA $4000, SP

    MOVE.B #1, -(SP)
    MOVE.B #2, -(SP)
    MOVE.B #3, -(SP)
    MOVE.B #4, -(SP)

    MOVE.B (SP)+, D1
    MOVE.B (SP)+, D1
    MOVE.B (SP)+, D1
    MOVE.B (SP)+, D1

END:

;Review questions, what is the purpose of Address Register SP (Stack Pointer)?
;Address Register SP: Points to the top of the stack in memory and is used to manage stack operations (push and pop), subroutine calls, returns, and temporary data storage.

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
