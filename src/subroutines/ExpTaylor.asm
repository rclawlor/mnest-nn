.enum SubroutineArgsB
	exptaylor_x	.dsb 2
	exptaylor_counter	.dsb 1
	exptaylor_factorial	.dsb 2
	exptaylor_product	.dsb 2
	exptaylor_temp		.dsb 2
	exptaylor_result	.dsb 2
.ende
ExpTaylor:
	lda #$01
	sta exptaylor_factorial+1	; Initialise factorial to 1
	sta exptaylor_product+1
	sta exptaylor_result+1

	lda #$00
	sta exptaylor_counter	; Initialise counter to 0
	sta exptaylor_factorial
	sta exptaylor_product
	sta exptaylor_result
	@loop:
		; Increment counter
		inc exptaylor_counter

		; Calculate x^n
		lda exptaylor_x
		sta multiplyfixed_A
		lda exptaylor_x+1
		sta multiplyfixed_A+1

		lda exptaylor_product
		sta multiplyfixed_B
		lda exptaylor_product+1
		sta multiplyfixed_B+1

		jsr MultiplyFixed

		lda multiplyfixed_B+1
		sta exptaylor_product
		lda multiplyfixed_C
		sta exptaylor_product+1

		; Calculate n!
		lda #$00
		sta multiplyfixed_A
		lda exptaylor_counter
		sta multiplyfixed_A+1

		lda exptaylor_factorial
		sta multiplyfixed_B
		lda exptaylor_factorial+1
		sta multiplyfixed_B+1

		jsr MultiplyFixed

		lda multiplyfixed_B+1
		sta exptaylor_factorial
		lda multiplyfixed_C
		sta exptaylor_factorial+1

		; Calculate next term
		lda exptaylor_product
		sta dividefixed_A
		lda exptaylor_product+1
		sta dividefixed_A+1

		lda exptaylor_factorial
		sta dividefixed_B
		lda exptaylor_factorial+1
		sta dividefixed_B+1

		jsr DivideFixed

		lda dividefixed_result
		sta exptaylor_temp
		lda dividefixed_result+1
		sta exptaylor_temp+1

		; Add new term to current sum
		lda exptaylor_result
		sta addfixed_A
		lda exptaylor_result+1
		sta addfixed_A+1

		lda exptaylor_temp
		sta addfixed_B
		lda exptaylor_temp+1
		sta addfixed_B+1

		jsr AddFixed

		lda addfixed_A
		sta exptaylor_result
		lda addfixed_A+1
		sta exptaylor_result+1

		lda exptaylor_counter
		cmp EXP_TAYLOR_N
		bne @loop

	rts
