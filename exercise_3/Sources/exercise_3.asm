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
String:       FCC "Thanks for making Tron FUN !! :) ~12345 "
                   FCB $0D
                   FCB $0A
                   FCB $00
FLAG:        EQU $03
InputString:  RMB 128 ; Reserve 128 bytes of memory for input string


; code boi
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
        LDAA #FLAG ; Loads flag into accumulator A
        LDX #String ; Loads string into interger register X
        CMPA #$01
        BEQ sendString
        LDX #InputString
        CMPA #$02
        BEQ receiveString
        CMPA #$03
        BEQ readAndWriteString


;**************************************************************
;*                       Functions                            *
;**************************************************************

sendString:
        LDAA 1, X+ ; Will interate over all every character in string thats loaded into X
        BEQ mainLoop
        MOVB #mSCI1CR2_TE,SCI1CR2     ; mSCI1CR2_TE  // $0C
        BRCLR SCI1SR1,mSCI1SR1_TDRE,*
        STAA SCI1DRL ; Stores character in SCIDRL register to be sent over serial port
        LDAB #17 ; should be 17.5 but round down from random overflow
        JSR delay  ; Branches to delay subroutine before returning 
        BRA sendString

receiveString:
        MOVB #mSCI1CR2_RE,SCI1CR2 ; bit mask to read to indicate byte can be read
        BRCLR SCI1SR1, mSCI1SR1_RDRF,* ; Loops back to previous line until a character has been recieved 
        LDAA SCI1DRL
        STAA 1, X+ ; stores character in X and moves the X pointer one byte along
        CMPA #$0D ;Carriage return 
        BEQ mainLoop ; branches back to mainloop once a carriage return has been receieved
        BRA receiveString ; else branches back to the start and reads more characters

readAndWriteString:
        MOVB #mSCI1CR2_RE,SCI1CR2 ; bit mask to read
        BRCLR SCI1SR1, mSCI1SR1_RDRF,*
        LDAA SCI1DRL
        STAA 1, X+  ; Loads and stores a new line character at the end of the string
        CMPA #$0D ;Carriage return 
        BEQ parsing  ; branches to parsing once a carriage return has been detected
        BRA readAndWriteString

    parsing:
          LDAA #$0A
          STAA 1, X+ ; Loads and stores a new line character at the end of the string
          LDAA #$00
          STAA 1, X+ ;  Loads and stores a NULL character at the end of the string
          LDX #InputString ; resets pointer to the beginning of intput string 

    beginWrite:
          MOVB #mSCI1CR2_TE,SCI1CR2  ; bitmask to write
          BRCLR SCI1SR1,mSCI1SR1_TDRE,*
          LDAA 1, X+
          BEQ mainLoop ; branches to mainloop if NULL

          STAA SCI1DRL ; stores A into SCI1DRL register to be output 
          LDAB #17 ; should be 17.5 but round down from random overflow
          JSR delay
          BRA beginWrite


;**************************************************************
;*                         Delays                             *
;**************************************************************

delay:
        LDY #60000 ;set to 60000 for 1s

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

 RTS


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
