; -------------------- DivideFixed ----------------------
;
; Description:
; 		Divides 16 bit fixed point number A by B
; 		Adapted from https://llx.com/Neil/a2/mult.html
;
; Inputs:
; 		dividefixed_A - 2 byte - dividend
; 		dividefixed_B - 2 byte - divisor
; 
; Outputs:
;		dividefixed_result - 2 byte - fixed point result
;
; ------------------------ Vars -------------------------
.enum SubroutineArgs
	dividefixed_A_ext	.dsb 1
	dividefixed_result	.dsb 1
	dividefixed_A		.dsb 2
	dividefixed_B 		.dsb 4
	dividefixed_rem		.dsb 4
	dividefixed_temp	.dsb 4
.ende
; ------------------------ Code -------------------------
DivideFixed:
	LDA #$00      			;Initialize REM to 0
    STA dividefixed_rem
    STA dividefixed_rem+1
	STA dividefixed_rem+2
	STA dividefixed_rem+3
	STA dividefixed_result
	STA dividefixed_result+1
	STA dividefixed_B+2
	STA dividefixed_B+3
    LDX #$20     			;There are 32 bits in NUM1
@loop_1:
	ASL dividefixed_A-2   	;Shift hi bit of NUM1 into REM
	ROL dividefixed_A-1
	ROL dividefixed_A
	ROL dividefixed_A+1		;(vacating the lo bit, which will be used for the quotient)
	
	ROL dividefixed_rem
	ROL dividefixed_rem+1
	ROL dividefixed_rem+2
	ROL dividefixed_rem+3

	LDA dividefixed_rem
	SEC         			;Trial subtraction
	SBC dividefixed_B
	STA dividefixed_temp

	LDA dividefixed_rem+1
	SBC dividefixed_B+1
	STA dividefixed_temp+1

	LDA dividefixed_rem+2
	SBC dividefixed_B+2
	STA dividefixed_temp+2

	LDA dividefixed_rem+3
	SBC dividefixed_B+3
	BCC @loop_2      		;Did subtraction succeed?
	STA dividefixed_rem+3   ;If yes, save it
	LDA dividefixed_temp+2
	STA dividefixed_rem+2
	LDA dividefixed_temp+1
	STA dividefixed_rem+1
	LDA dividefixed_temp
	STA dividefixed_rem

	INC dividefixed_A-2    	;and record a 1 in the quotient
@loop_2:
	DEX
	BNE @loop_1

	RTS
