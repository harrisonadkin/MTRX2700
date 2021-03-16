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
String:     FCC "1234"
            FCB $00
HexString:  DS.B 64
LEDON:      EQU $01

 
; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS #RAMEnd+1

            CLI


mainLoop:
            LDX #String
            LDY #HexString
            
            
  switchStatement:
            LDAA 1, X+
            BEQ mainLoop
            
            CMPA #$31
            BEQ changeOne
            
            CMPA #$32
            BEQ changeTwo
            
            CMPA #$33
            BEQ changeThree
            
            CMPA #$34
            BEQ changeFour
      
           

  changeOne:
           LDAB #$06
           BRA writeHex   
  
  changeTwo:
           LDAB #$5B
           BRA writeHex
  
  changeThree:
           LDAB #$4F
           BRA writeHex
  
  changeFour:
           LDAB #$66
           BRA writeHex
          
           
  writeHex:
           STAB 1, Y+
           BRA switchStatement





;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
 