*-----------------------------------------------------------
* Title      : practical_06_part2
* Written by : Kamil Salih
* Date       : 27/02/2026
* Description: This program sequentially demonstrates Trap #15 tasks 0 through 22 in numerical order—performing various input, output, formatting, keyboard, screen, and display operations—before terminating cleanly with Task 9.
*-----------------------------------------------------------
        ORG     $1000

START:

; ===============================
; Task 0 – Display string (length) with CR/LF
; ===============================
        LEA     MSG0,A1
        MOVE.W  #18,D1
        MOVE.B  #0,D0
        TRAP    #15

; ===============================
; Task 1 – Display string (length) without CR/LF
; ===============================
        LEA     MSG1,A1
        MOVE.W  #22,D1
        MOVE.B  #1,D0
        TRAP    #15

; ===============================
; Task 2 – Read string
; ===============================
        LEA     BUFFER,A1
        MOVE.B  #2,D0
        TRAP    #15

; ===============================
; Task 3 – Display signed number
; ===============================
        MOVE.L  #-12345,D1
        MOVE.B  #3,D0
        TRAP    #15

; ===============================
; Task 4 – Read number
; ===============================
        MOVE.B  #4,D0
        TRAP    #15

; ===============================
; Task 5 – Read single character
; ===============================
        MOVE.B  #5,D0
        TRAP    #15

; ===============================
; Task 6 – Display single character
; ===============================
        MOVE.B  #'Z',D1
        MOVE.B  #6,D0
        TRAP    #15

; ===============================
; Task 7 – Check pending key
; ===============================
        MOVE.B  #7,D0
        TRAP    #15

; ===============================
; Task 8 – Get time since midnight
; ===============================
        MOVE.B  #8,D0
        TRAP    #15

; ===============================
; Task 11 – Clear screen
; ===============================
        MOVE.W  #$FF00,D1
        MOVE.B  #11,D0
        TRAP    #15

; ===============================
; Task 12 – Keyboard echo off then on
; ===============================
        MOVE.B  #0,D1
        MOVE.B  #12,D0
        TRAP    #15

        MOVE.B  #1,D1
        MOVE.B  #12,D0
        TRAP    #15

; ===============================
; Task 13 – Display NULL string with CR/LF
; ===============================
        LEA     MSG13,A1
        MOVE.B  #13,D0
        TRAP    #15

; ===============================
; Task 14 – Display NULL string without CR/LF
; ===============================
        LEA     MSG14,A1
        MOVE.B  #14,D0
        TRAP    #15

; ===============================
; Task 16 – Adjust display properties
; ===============================
        MOVE.B  #1,D1
        MOVE.B  #16,D0
        TRAP    #15

; ===============================
; Task 17 – Display string + number
; ===============================
        LEA     MSG17,A1
        MOVE.L  #2026,D1
        MOVE.B  #17,D0
        TRAP    #15

; ===============================
; Task 18 – Display string + read number
; ===============================
        LEA     MSG18,A1
        MOVE.B  #18,D0
        TRAP    #15

; ===============================
; Task 19 – Key state check
; ===============================
        MOVE.L  #$00000000,D1
        MOVE.B  #19,D0
        TRAP    #15

; ===============================
; Task 20 – Display signed number in field width
; ===============================
        MOVE.L  #1234,D1
        MOVE.B  #8,D2
        MOVE.B  #20,D0
        TRAP    #15

; ===============================
; Task 21 – Set font color/style
; ===============================
        MOVE.L  #$0000FF00,D1   ; Green
        MOVE.B  #1,D2           ; Bold
        MOVE.B  #21,D0
        TRAP    #15

; ===============================
; Task 22 – Read character at row/col
; ===============================
        MOVE.L  #$00010001,D1
        MOVE.B  #22,D0
        TRAP    #15

; ===============================
; Task 9 – Terminate program (MUST be last)
; ===============================
        MOVE.B  #9,D0
        TRAP    #15

        SIMHALT

; ===============================
; DATA SECTION
; ===============================

MSG0    DC.B 'Task 0 Example',0
MSG1    DC.B 'Task 1 Example',0
MSG13   DC.B 'Task 13 Example',0
MSG14   DC.B 'Task 14 Example',0
MSG17   DC.B 'Year: ',0
MSG18   DC.B 'Enter a number: ',0

BUFFER  DS.B 82

        END START        END     START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
