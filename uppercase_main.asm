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
String:     FCC "ALL. lower"
            FCB $00


; code section
            ORG   ROMStart



Entry:
_Startup:
            LDS #RAMEnd+1
            
            CLI
            
            
         
mainLoop:
            LDX #String
innerLoop:  LDAA 1, X+
            BEQ mainLoop
            CMPA #97
            BHS upperLoop
            CMPA #90
            BLS parsing
 
            
upperLoop:
            STAA $2010
            bra innerLoop
            
parsing:
            CMPA #65
            BHS lowerLoop
            bra innerLoop
            
lowerLoop: 
            STAA $3010
            bra innerLoop 
            


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
