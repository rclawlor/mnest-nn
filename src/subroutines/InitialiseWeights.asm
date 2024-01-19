InitialiseWeights:
	; Load pointer with weight location
	lda #<weight_start_index
    sta weight_pointer_l
    lda #>weight_start_index
    sta weight_pointer_h
	
	; Initialise layer loop counter
	lda #$00
	sta neuron_inputs
	sta neuron_counter
	sta weight_counter
	tax
	tay

	lda LAYERS
	clc
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
		@neuron_loop:
			jsr GenerateWeight

			dec neuron_counter
			bne @neuron_loop
		dec layer_counter
		bne @layer_loop

	lda #$09
	sta $0030
	rts

GenerateWeight:
	lda neuron_inputs
	sta neuron_input_counter
	@input_loop:
		lda neuron_counter
		clc
		adc #$01
		sta (weight_pointer_l), y

		; Increment weight pointer
		iny
		sty $0040
		cpy #$00
		bne ++
		inc weight_pointer_h
		++
		dec neuron_input_counter
		bne @input_loop
		
	rts
