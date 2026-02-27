*-----------------------------------------------------------
* Title      : practical_06_part5
* Written by : Kamil Salih
* Date       : 27/02/2026
* Description: This program initializes a health value, subtracts 10 from it in a game loop, and then displays the label “Health:” followed by the updated health value on the screen.
*-----------------------------------------------------------
START:
    MOVE.L  #HEALTH, -(SP)
    JSR     GAME_LOOP
    BSR     HEADS_UP_DISPLAY
    BRA     END

GAME_LOOP:
    MOVEA.L 4(SP), A1
    SUB.B   #10, (A1)
    RTS

HEADS_UP_DISPLAY:
    LEA     MESSAGE, A1
    MOVE.B  #14, D0
    TRAP    #15
    MOVE.B  HEALTH, D1
    MOVE.B  #3, D0
    TRAP    #15
    RTS

HEALTH:   DC.B 100
MESSAGE:  DC.B 'Health: ', 0


;Review questions parameters to subroutines can be passed through the stack what other functions can be achieved through the stack, what observations have you made when opening VIEW | STACK ?
;In this program, the stack is used to pass the address of HEALTH to GAME_LOOP and to store the return address when JSR is executed.
;In VIEW | STACK, you would see the pushed parameter first, then the return address above it, and after RTS, the return address is removed and the stack pointer moves back up.
;Because this program does not clean up the parameter after the subroutine call, the value pushed with MOVE.L #HEALTH, -(SP) remains on the stack after RTS, meaning the stack pointer does not fully return to its original position unless manually adjusted.
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
