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
String:     FCC "ALL. lower"  ; stores string
            FCB $00 ; appends end of string with 0 character
UpperVal:   EQU #$5F ; stores 0101 1111 binary
LowerVal:   EQU #$20 ; stores 0010 0000 binary


; code section
            ORG   ROMStart



Entry:
_Startup:
            LDS #RAMEnd+1

            CLI



mainLoop:
            LDX #String ; begin by loading memory address at label string
innerLoop:  LDAA 1, X+  ; load first character in string into A, and increment
            BEQ mainLoop  ; break if 0 to stop looping at end
            CMPA #97  ; compare A to 97 to see if capital / lowercase
            BHS upperLoop ; break if ___ to uppercase loop
            CMPA #90  ; compare A to 90 to see if capital / lowercase
            BLS parsing ; break to parsing if ___


upperLoop:
            STAA $2010
            BRA innerLoop ; break back to look at next character

parsing:
            CMPA #65  ; compare to 65 to find if letter, space or fullstop
            BHS lowerLoop ; break if ___ to lower
            BRA innerLoop ; otherwise break back to inner to look at next character

lowerLoop:
            STAA $3010
            BRA innerLoop ; break back to look at next character



;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
