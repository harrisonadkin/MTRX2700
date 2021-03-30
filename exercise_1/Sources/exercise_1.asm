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
OutputString: DS.B 256 ; Memory reserved for appended string
Flag:         EQU $01 ; Determines operating mode 
UpperVal:     EQU $5F ; bitmask values to make lowercase character uppercase
LowerVal:     EQU $20 ; bitmask values to make uppercase character lowercase




; code section
            ORG   ROMStart



Entry:
_Startup:
            LDS #RAMEnd+1

            CLI



mainLoop:
            LDY #OutputString
            LDX #String ; begin by loading memory address at label string
            LDAB #Flag   ; Loads flag into accumulator B
            CMPB #$01
            BEQ makeUpper ; If Flag = 1, make all letters uppercase
            CMPB #$02
            BEQ makeLower ; If Flag = 2, make all letters lowercase
            CMPB #$03
            BEQ makeCapital ;If Flag = 3, Capitalise only the first letter of each word
            CMPB #$04
            BEQ initialSentence ;If Flag = 4, Capitalise only the first letter of the first word of a sentence 

makeUpper:
            LDAA 1, X+ ; Everytime makeUpper is entered the accumulator A pointer (X) is moved by 1 byte and loaded back into accumulator A
            BEQ mainLoop
            CMPA #$61
            BHS upperLoop ;if value in accumulator A is higher then hex $61 then the upperLoop is entered  
            BRA writeOutput ; Enters writeOutput to save character (originally uppercase)


  upperLoop:
              ANDA #UpperVal ; AND's hex value $5F to change characters ASCII value to its uppercase form
              BRA writeOutput ; Enters writeOutput to save character (originally lowercase)


makeLower:                                       
            LDAA 1, X+ ; Everytime makeLower is entered the accumulator A pointer (X) is moved by 1 byte and loaded back into accumulator A
            BEQ mainLoop
            CMPA #$5A
            BLS parsing ;if value in accumulator A is lower then hex $5A then the parsing is entered, parsing is used to check for non alphabetical characters
            BRA writeOutput ; Enters writeOutput to save character (originally Lowercase)

  parsing:
              CMPA #$41  ; compare to 41 to find if letter, space or fullstop
              BHS lowerLoop ; branch if higher than 41 to lowerLoop (is a letter)
              BRA writeOutput ; Enters writeOutput to save character (originally non-letter)

  lowerLoop:
              ORAA #LowerVal; OR's hex value $20 to change characters ASCII value to its lowercase form
              BRA writeOutput ; Branches to writeOutput to save character (originally Uppercase)

makeCapital:
            LDAA 1, X+
            BEQ mainLoop
            CMPA #$20  
            BEQ capitalLoop ;if value in accumulator A is equal to hex $20 then the capitalLoop is branched to, hex 20 is equal to a space
            BRA lowerLoop

    capitalLoop:
              STAA 1, Y+ ; the space ($20) is stored and then the pointer Y is moved onto the next memory position
              LDAA 1, X+ ; accumulator A pointer is moved to the next character
              CMPA #$61
              BHS upperLoop ;if value in accumulator A is higher/same as hex 61 it is a lowercase letter, thus it branches to upperLoop
              BRA writeOutput ; if lower then it is either a non-aphlabetical character or an uppercase character and thus is just stored

initialSentence:
            BRA makeCapital ; Always capitalises the first letter loaded into accumulator A

  makeSentence:
              LDAA 1, X+ ; accumulator A pointer is moved to the next character
              BEQ mainLoop

              CMPA #$2E ; 2E = fullstop (.)
              BEQ sentenceLoop ; enters if a fullstop is in accumulator A 
              BRA lowerLoop ; else all aphlabetical characters are made into lowercase ones by branching to lowerLoop

      sentenceLoop:
                STAA 1, Y+ ; the fullstop ($2E) is stored and then the pointer Y is moved onto the next memory position 
                BRA makeCapital ; the first character after a fullstop is capitalised by branching to makeCaptial

writeOutput:
           STAA 1, Y+ ; Stores changed value in accumulator A into memory and then moves the pointer forward by 1 ready for the next value
           CMPB #$01  ; enters the appropriate branch based on flag value
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