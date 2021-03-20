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
String:     FCC "0123456789"
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
FLAG:       EQU $03

 
; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS #RAMEnd+1

            CLI



always:
            LDX #String

mainLoop:
            
            LDY #Digits
            
                        
            MOVB #$0F,DDRP               ; set ddrp to 15 ????? (output port P - 7 seg)
            MOVB #$FF,DDRB               ; set ddrn to 255
            MOVB #$00,DDRH               ; set push button for input
            MOVB #$FF,PTP

            
            
            LDAA #FLAG
            CMPA #$01
            BEQ readButton
            CMPA #$02
            BEQ drawString              
            CMPA #$03               
            BEQ numScroll
            
            
            
  readButton:           
            BCLR PTP, $01           ; which 7Seg 01 is 1, 02 is 2, 04 is 3, 08 is 4
            LDAA PTH
            CMPA #00
            BEQ mappingFunction
            BRA readButton
  
  
  drawString:
            LDAA 1,Y+
            STAA PTP
            BRA mappingFunction
           
            
  numScroll:
            LDAA 1,Y+
            BEQ mainLoop
            STAA PTP
            BRA mappingFunction       
                                                        
                       
            
  mappingFunction:
            LDAA 1, X+
            BEQ mainLoop
            
            LDAB #ONE
            CMPA #$31
            BEQ writeHex
            
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
            
            BRA mappingFunction   ; note this loops if a letter not to display it (important for ex 4)
      
           
                 
  writeHex:
           STAB PORTB
           LDAB #20
           PSHX
           PSHY
           BRA longDelay ; short delay comment out DBNE B
           
           
  longDelay:
           LDY #6000
           
      shortDelay:
           PSHA
           PULA
           PSHA
           PULA
           PSHA
           PULA
           PSHA
           PULA
           DBNE Y,shortDelay
           DBNE B,longDelay
   
   PULY
   PULX
   
   LDAA #FLAG
   CMPA #$01
   BEQ readButton
   CMPA #$02
   BEQ drawString                 
   CMPA #$03                       
   BEQ numScroll





;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
 