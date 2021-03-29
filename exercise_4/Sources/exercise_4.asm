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
        MOVB #$0F,DDRP               ; set ddrp to 15
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
        BRCLR SCI1SR1, mSCI1SR1_RDRF,* ; break unless there is an input to read
        LDAA SCI1DRL ; else load that into accumulator a
        STAA 1, X+ ; store in X and increment
        CMPA #$0D ; compare to carriage return
        BEQ parsing ; if carriage return, string is entered and we continue
        BRA readString ; else keep looking

    parsing:
          LDAA #$00 ; load end null char into A
          STAA 1, X+ ; store it into X string
          LDX #InputString ; restart the pointer to the first val of X

readSwitch:
        LDAA PTH ; load the button state
        CMPA #$00 ; compare to zero
        BEQ upperCase ; if zero uppercase
        BRA capitalCase ; else capitalCase

upperCase:
        LDAA 1, X+ ; load the inputted string character by character
        CMPA #$0D ; if its the carriage return then start writing
        BEQ resetPointer ; ""
        CMPA #$61 ; compare to hex 61 to see if we must capitalise
        BHS upperLoop ; if 61 or higher, jump to capitalise loop
        JSR storeOutput ; else, it must be a capital or a non-letter and we simply write
        BRA upperCase ; continue to cycle through input string

    upperLoop:
          ANDA #UpperVal ; andA turns into capital
          JSR storeOutput ; write A
          BRA upperCase ; continue to cycle through input string

capitalCase:
        LDAA 1, X+ ; load and increment
        CMPA #$0D ; compare to carriage return
        BEQ resetPointer ; if carriage return, begin writing
        CMPA #$20 ; compare to space
        BEQ capitalLoop ; if equal start capitalising
        ORAA #LowerVal ; else make lowercase
        JSR storeOutput ; and write
        BRA capitalCase ; continue cycling

    capitalLoop:
          JSR storeOutput ; write the space
          LDAA 1, X+ ; go to the next character
          CMPA #$61 ; compare to capital
          BHS innerLoop ; if not capital make capital
          JSR storeOutput ; else write
          BRA capitalCase ; continue cycling

        innerLoop:
            ANDA #UpperVal ; if not capital make capital
            JSR storeOutput ; write to output
            BRA capitalCase ; continue cycline

storeOutput:
        STAA 1, Y+ ; function to store the new string to output
        RTS

resetPointer:
        LDAA #$0D ; add carriage return to output
        JSR storeOutput
        LDAA #$0A ; add vertical line to output
        JSR storeOutput
        LDAA #$00 ; add null char to output
        JSR storeOutput
        LDY #OutputString ; reset pointer to beginning of output string
        
beginWrite:
        MOVB #mSCI1CR2_TE,SCI1CR2  ; bitmask to write
        BRCLR SCI1SR1,mSCI1SR1_TDRE,* ; if nothing to write, don't write
        LDAA 1, Y+ ; load output string and increment
        CMPA #$00 ; compare to end character
        LBEQ mainLoop ; if end character finish task
        STAA SCI1DRL ; else write the output to serial
        BRA beginWrite ; continue writing



;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
