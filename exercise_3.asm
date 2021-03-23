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
String:     FCC "Thanks for making Tron FUN !! :) ~12345 "
            FCB $0D
            FCB $00
Flag:       EQU $01


; code boi
            ORG ROMStart


Entry:
 _Startup:
            LDS #RAMEnd+1
            CLI


mainLoop:
        LDX #String
        MOVB #$00,SCI1BDH
        MOVB #$9C,SCI1BDL
        MOVB #$4C,SCI1CR1
        MOVB #$0C,SCI1CR2
        MOVB #$00,SCI1DRL
        LDAA #Flag
        CMPA $01
        BEQ sendString
        CMPA $02
        BEQ receiveString


sendString:
        LDAA 1, X+
        BEQ mainLoop
        BRA outputChar

receiveString:
        LDAA 1, X+
        BEQ mainLoop
        BRA inputChar

;sendBreak:
 ;       BSET SCI1CR2,mSCI1CR2_SBK
  ;      JSR delay
   ;     BCLR SCI1CR2,mSCI1CR2_SBK
    ;    RTS

outputChar:
        BRCLR SCI1SR1,mSCI1SR1_TDRE,*
        STAA  SCI1DRL
        LDAB #17
        BRA delay


inputChar:
       ; solve logic


delay:
        LDY #60000

   delayLoop:
          PSHA
          PULA
          PSHA
          PULA
          PSHA
          PULA
          PSHA
          PULA
          DBNE Y,delayLoop
          DBNE B,delay

 BRA sendString


 


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
