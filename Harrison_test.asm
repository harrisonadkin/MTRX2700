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
Counter       DS.W 1
FiboRes       DS.W 1

 ; Our constants.
String:       FCC "ALL. lower"  ; stores string
              FCB $00 ; appends end of string with 0 character
UpperVal:     EQU #$5F ; stores 0101 1111 binary
LowerVal:     EQU #$20 ; stores 0010 0000 binary
OutputString: DS.B 16
Operation:    EQU #$01 ; pick which operation (all upper, all lower, caps, sentence)



; code section
            ORG   ROMStart



Entry:
_Startup:
            LDS #RAMEnd+1

            CLI



mainLoop:
            LDY #OutputString
            LDX #String ; begin by loading memory address at label string
            LDAB #Operation
            CMPB #$01
            BEQ makeUpper
            CMPB #$02
            BEQ makeLower
            CMPB #$03
            BEQ makeCapital
            CMPB #$04 makeSentence

makeUpper:
            LDAA 1, X+
            BEQ mainLoop
            CMPA #$61
            BHS upperLoop

  upperLoop:
              ANDA UpperVal
              STAA 0,Y+
              BRA makeUpper ; break back to look at next character

makeLower:
            LDAA 1, X+
            BEQ mainLoop
            CMPA #$5A
            BLS parsing

  parsing:
              CMPA #$41  ; compare to 41 to find if letter, space or fullstop
              BHS lowerLoop ; break if higher than 41 to lower (is a letter)
              BRA makeLower ; otherwise break back to inner to look at next character

  lowerLoop:
              ORAA LowerVal
              STAA 0, Y+ ; is this gonna reset the store @ 0 ??
              BRA makeLower ; break back to look at next character

makeCapital:
            LDAA 1, X+
            BEQ mainLoop
            CMPA #$20
            BEQ capitalLoop

    capitalLoop:









;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
