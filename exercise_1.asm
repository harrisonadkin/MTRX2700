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
String:       FCB $20
              FCC "plEaSe mAke me. seNtence Case. a"  ; stores string
              FCB $00 ; appends end of string with 0 character
OutputString: DS.B 256
Flag:         EQU $01
UpperVal:     EQU $5F
LowerVal:     EQU $20




; code section
            ORG   ROMStart



Entry:
_Startup:
            LDS #RAMEnd+1

            CLI



mainLoop:
            LDY #OutputString
            LDX #String ; begin by loading memory address at label string
            LDAB #Flag
            CMPB #$01
            BEQ makeUpper
            CMPB #$02
            BEQ makeLower
            CMPB #$03
            BEQ makeCapital
            CMPB #$04
            BEQ initialSentence

makeUpper:
            LDAA 1, X+
            BEQ mainLoop
            CMPA #$61
            BHS upperLoop
            BRA writeOutput


  upperLoop:
              ANDA #UpperVal
              BRA writeOutput


makeLower:
            LDAA 1, X+
            BEQ mainLoop
            CMPA #$5A
            BLS parsing
            BRA writeOutput

  parsing:
              CMPA #$41  ; compare to 41 to find if letter, space or fullstop
              BHS lowerLoop ; break if higher than 41 to lower (is a letter)
              BRA writeOutput

  lowerLoop:
              ORAA #LowerVal
              BRA writeOutput

makeCapital:
            LDAA 1, X+
            BEQ mainLoop
            CMPA #$20
            BEQ capitalLoop
            BRA lowerLoop

    capitalLoop:
              STAA 1, Y+
              LDAA 1, X+
              CMPA #$61
              BHS upperLoop
              BRA writeOutput

initialSentence:
            BRA makeCapital

  makeSentence:
              LDAA 1, X+
              BEQ mainLoop

              CMPA #$2E
              BEQ sentenceLoop
              BRA lowerLoop

      sentenceLoop:
                STAA 1, Y+
                BRA makeCapital

writeOutput:
           STAA 1, Y+
           CMPB #$01
           BEQ makeUpper
           CMPB #$02
           BEQ makeLower
           CMPB #$03
           BEQ makeCapital
           CMPB #$04
           BEQ makeSentence






;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
