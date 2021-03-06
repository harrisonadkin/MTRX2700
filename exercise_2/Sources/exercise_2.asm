;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions
		INCLUDE 'derivative.inc'

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

            ORG RAMStart

 ; Insert here your data definition.
Counter     DS.W 1
FiboRes     DS.W 1

 ; Our constants.
String:     FCC "0123"
            FCB $00
Digits:     dc.b $0E, $0D, $0B, $07, $00
ONE:        EQU $06
TWO:        EQU $5B
THREE:      EQU $4F
FOUR:       EQU $66
FIVE:       EQU $6D
SIX:        EQU $7D
SEVEN:      EQU $07
EIGHT:      EQU $7F
NINE:       EQU $6F
ZERO:       EQU $3F
FLAG:       EQU $02


; code section
            ORG   ROMStart

Entry:
_Startup:
            LDS #RAMEnd+1
            CLI

mainLoop:
            LDX #String
            LDY #Digits

            MOVB #$0F,DDRP               ; set ddrp to 15 ????? (output port P - 7 seg)
            MOVB #$FF,DDRB               ; set ddrn to 255
            MOVB #$00,DDRH               ; set push button for input
            MOVB #$FF,PTP

            LDAA #FLAG ; load FLAG into accumulator A
            CMPA #$01 ; ; if FLAG = 1, execute readButton function
            BEQ readButton
            CMPA #$02 ; if FLAG = 2, execute drawString function
            BEQ drawString
            CMPA #$03 ; if FLAG = 3, execute numScroll function
            BEQ numScroll


  mappingFunction:
            LDAA 1, X+ ; load into A and increment each time
            BEQ mainLoop ; go to the mainloop

            LDAB #ONE
            CMPA #$31 ; compare the hex values (numbers 1 - 9 respectively)
            BEQ writeHex ; write if equal

            LDAB #TWO
            CMPA #$32
            BEQ writeHex

            LDAB #THREE
            CMPA #$33
            BEQ writeHex

            LDAB #FOUR
            CMPA #$34
            BEQ writeHex

            LDAB #FIVE
            CMPA #$35
            BEQ writeHex

            LDAB #SIX
            CMPA #$36
            BEQ writeHex

            LDAB #SEVEN
            CMPA #$37
            BEQ writeHex

            LDAB #EIGHT
            CMPA #$38
            BEQ writeHex

            LDAB #NINE
            CMPA #$39
            BEQ writeHex

            LDAB #ZERO
            CMPA #$30
            BEQ writeHex

            BRA mappingFunction


  writeHex:
           STAB PORTB ; write to port B
           LDAA #FLAG ; load flag onto accumulator
           CMPA #$01
           BEQ readButton ; branch to readButton function if equal
           BRA delay ; go to our delay function



;**************************************************************
;*                        Functions                           *
;**************************************************************

 drawString:
              LDAA 1,Y+ ; load whatever Y is pointing to and increment the index of Y to point to the second character
              STAA PTP ; store to 7 segment
              JSR mappingFunction ; jump to subroutine mappingFunction
              BRA drawString ; always branch to

 readButton:
              LDAA #$0E ; load accumulator A into the first binary 7seg LED
              STAA PTP ; store TO 7 SEG
              LDAA PTH ; load data to DIP switches
              CMPA #$00
              BNE readButton
              PSHX
              JSR buttonDelay
              PULX
              JSR mappingFunction
              BRA readButton


 numScroll:
              LDY #6000 ; ; 6000 x 4 = 24,000 cycles = 1ms

      dispSeg1:
                LDAA #$0E
                STAA PTP ; store to first 7 seg dip switch
                LDAA Y ; load into Y
                CMPA 0
                BEQ nextChar
                JSR mappingFunction
                PSHX ; push X into stack

      dispSeg2:
                LDAA #$0D
                STAA PTP
                LDAA Y
                CMPA 0
                BNE noHold
                PSHX
                BRA dispSeg3

          noHold:
                  JSR mappingFunction


      dispSeg3:
                LDAA #$0B
                STAA PTP
                JSR mappingFunction

      dispSeg4:
                LDAA #$07
                STAA PTP
                JSR mappingFunction

      nextString:
                 PULX ; pull value in X register out of stack
                 LDAA Y ; load Y into A
                 CMPA 0
                 BEQ numScroll
                 DEY ; decrement index register Y
                 BRA dispSeg1

   nextChar:
              INX ; increment index of X and go to next character
              JSR mappingFunction ; go to mappingFunction



;**************************************************************
;*                         Delays                             *
;**************************************************************

  delay:
      PSHX ; push register X into stack
      LDX #60 ; set to 6000 for scroll

    innerLoop1:
        LDAA #100
    innerLoop2:
        PSHA
        PULA
        PSHA
        PULA
      DBNE A, innerLoop2
      DBNE X, innerLoop1
      PULX
  RTS

  buttonDelay:
      LDX #60000

    innerButtonLoop1:
        LDAA #20
    innerButtonLoop2:
        PSHA
        PULA
        PSHA
        PULA
      DBNE A, innerButtonLoop2
      DBNE X, innerButtonLoop1

  RTS


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
