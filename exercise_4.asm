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

 ; Defining memory for input + output string
InputString:  RMB 128
OutputString: RMB 128

 ; Define 7Seg Digits
Digits:     dc.b $0E, $0D, $0B, $07, $00
 ; Save constants
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
UpperVal:   EQU $5F
LowerVal:   EQU $20

; Begin Code
            ORG ROMStart

Entry:
 _Startup:
            LDS #RAMEnd+1
            CLI

mainLoop:

        MOVB #$00,SCI1BDH  ; baud rate
        MOVB #$9C,SCI1BDL  ; baud rate 156 decimal
        MOVB #$00,SCI1CR1  ; always 0
        MOVB #$00,SCI1DRL
        MOVB #$0F,DDRP               ; set ddrp to 15 (output port P - 7 seg)
        MOVB #$FF,DDRB               ; set ddrb to 255
        MOVB #$00,DDRH               ; set push button for input
        MOVB #$FF,PTP                ; set 7seg for output
        LDX #InputString
        LDY #OutputString
        

;**************************************************************
;*                       Functions                            *
;**************************************************************


readString:
        MOVB #mSCI1CR2_RE,SCI1CR2 ; bit mask to read
        BRCLR SCI1SR1, mSCI1SR1_RDRF,*
        LDAA SCI1DRL
        STAA 1, X+
        CMPA #$0D
        BEQ parsing
        BRA readString

    parsing:
          LDAA #$00
          STAA 1, X+
          LDX #InputString
          
readSwitch:
        LDAA PTH
        CMPA #$00
        BEQ upperCase
        BRA capitalCase
        
upperCase:
        LDAA 1, X+
        CMPA #$0D
        BEQ resetPointer
        CMPA #$61
        BHS upperLoop
        JSR storeOutput
        BRA upperCase
        
    upperLoop:
          ANDA #UpperVal
          JSR storeOutput
          BRA upperCase
         
capitalCase:
        LDAA 1, X+
        CMPA #$0D
        BEQ resetPointer
        CMPA #$20
        BEQ capitalLoop
        ORAA #LowerVal
        JSR storeOutput
        BRA capitalCase
       
    capitalLoop:
          JSR storeOutput
          LDAA 1, X+
          CMPA #$61
          BHS innerLoop
          JSR storeOutput
          BRA capitalCase
        
        innerLoop:
            ANDA #UpperVal
            JSR storeOutput
            BRA capitalCase
        
storeOutput:
        STAA 1, Y+
        RTS
        
resetPointer:
        LDAA #$0D
        JSR storeOutput
        LDAA #$0A
        JSR storeOutput
        LDAA #$00
        JSR storeOutput 
        LDY #OutputString
        
beginWrite:
        MOVB #mSCI1CR2_TE,SCI1CR2  ; bitmask to write
        BRCLR SCI1SR1,mSCI1SR1_TDRE,*
        LDAA 1, Y+
        CMPA #$00
        LBEQ mainLoop
        STAA SCI1DRL
        BRA beginWrite



;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector