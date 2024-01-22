ForwardPass:
	; Load pointer with weight location
	lda #<weight_start_index
    sta weight_pointer_l
    lda #>weight_start_index
    sta weight_pointer_h

	; Load pointer with input location
	lda #<input_start_index
	sta input_pointer_l
	sta temp_pointer_l
	lda #>input_start_index
	sta input_pointer_h
	sta temp_pointer_h

	; Load pointer with input location
	lda #<input_start_index
	sta output_pointer_l
	lda #>input_start_index
	sta output_pointer_h

	; Initialise layer loop counter
	lda #$00
	sta neuron_inputs
	sta neuron_counter
	sta weight_counter
	sta forwardpass_weight_index
	sta forwardpass_input_index
	ldx #$00
	ldy #$00

	; Move network inputs
	lda Layers, x
	sta neuron_input_counter
	@initialise_inputs:
		lda NetworkInput, x
		sta (input_pointer_l), y
		inx
		iny
		jsr IncrementOutputPointer
		lda NetworkInput, x
		sta (input_pointer_l), y
		inx
		iny
		jsr IncrementOutputPointer
		dec neuron_input_counter
		lda neuron_input_counter
		cmp #$00
		bne @initialise_inputs
	
	ldx #$00
	ldy #$00
	lda LAYERS
	sec
	sbc #$01
	sta layer_counter
	@layer_loop:
		lda Layers, x
		clc
		adc #$01			; Add 1 for bias input
		sta neuron_inputs
		inx					; Select next layer neuron count
		lda Layers, x
		sta neuron_counter

		lda #$00
		sta forwardpass_input_index
		@neuron_loop:
			jsr CalculateOutput
			ldy #$00
			lda neuron_output
			sta (output_pointer_l), y	
 			jsr IncrementOutputPointer
			lda neuron_output+1
			sta (output_pointer_l), y
			jsr IncrementOutputPointer
			dec neuron_counter
			lda neuron_counter
			cmp #$00
			bne @neuron_loop
		dec layer_counter
		lda layer_counter
		cmp #$00
		beq +
			lda neuron_inputs
			sec
			sbc #$01			; Remove bias in count
			sta neuron_input_counter
			@change_input:
				jsr IncrementTempPointer
				jsr IncrementTempPointer
				dec neuron_input_counter
				lda neuron_input_counter
				cmp #$00
				bne @change_input
			jmp @layer_loop
		+
	
	rts

CalculateOutput:
	lda neuron_inputs			; Get number of inputs
	sec
	sbc #$01
	sta neuron_input_counter
	
	; Initialise output
	lda #$00
	sta neuron_output
	sta neuron_output+1

	; Initialise pointer
	lda temp_pointer_l
	sta input_pointer_l
	lda temp_pointer_h
	sta input_pointer_h
	@input_loop:
		; Load weights
		ldy #$00 ;forwardpass_weight_index
		lda (weight_pointer_l), y
		sta multiplyfixed_A

		jsr IncrementWeightPointer

		lda (weight_pointer_l), y
		sta multiplyfixed_A+1

		jsr IncrementWeightPointer
		
		; Load input
		ldy #$00
		lda (input_pointer_l), y
		sta multiplyfixed_B

		jsr IncrementInputPointer

		lda (input_pointer_l), y
		sta multiplyfixed_B+1

		jsr IncrementInputPointer

		; Multiply input by weight
		jsr MultiplyFixed
		
		; Add to current output
		lda multiplyfixed_B+1
		sta temp
		lda multiplyfixed_C
		sta temp+1
		lda temp
		sta addfixed_A
		lda temp+1
		sta addfixed_A+1

		lda neuron_output
		sta addfixed_B
		lda neuron_output+1
		sta addfixed_B+1
		jsr AddFixed
		lda addfixed_A
		sta neuron_output
		lda addfixed_A+1
		sta neuron_output+1

		dec neuron_input_counter
		bne @input_loop
	
	; Add bias term
	lda neuron_output
	sta addfixed_A
	lda neuron_output+1
	sta addfixed_A+1

	ldy #$00
	lda (weight_pointer_l), y
	sta addfixed_B

	jsr IncrementWeightPointer

	lda (weight_pointer_l), y
	sta addfixed_B+1

	jsr IncrementWeightPointer
	
	jsr AddFixed
	lda addfixed_A
	sta neuron_output
	lda addfixed_A+1
	sta neuron_output+1
		
	rts

IncrementWeightPointer:
	inc weight_pointer_l
	lda weight_pointer_l
	cmp #$00
	bne ++
		inc weight_pointer_h
	++
	rts

IncrementInputPointer:
	inc input_pointer_l
	lda input_pointer_l
	cmp #$00
	bne ++
		inc input_pointer_h
	++
	rts

IncrementOutputPointer:
	inc output_pointer_l
	lda output_pointer_l
	cmp #$00
	bne ++
		inc output_pointer_h
	++
	rts

IncrementTempPointer:
	inc temp_pointer_l
	lda temp_pointer_l
	cmp #$00
	bne ++
		inc temp_pointer_h
	++
	rts
