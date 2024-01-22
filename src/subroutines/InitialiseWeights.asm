; Initialises weights using Xavier initialisation
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
		@neuron_loop:
			jsr GenerateWeight

			dec neuron_counter
			bne @neuron_loop
		dec layer_counter
		bne @layer_loop
	
	rts


GenerateWeight:
	lda neuron_inputs
	sec
	sbc #$01
	sta neuron_input_counter
	@input_loop:
		lda #$00
		sta divideweight_weight
		lda #$01
		sta divideweight_weight+1
		lda neuron_inputs
		sec
		sbc #$01						; remove bias in count
		sta divideweight_prev_neurons
		
		jsr DivideWeight

		lda divideweight_weight
		sta (weight_pointer_l), y

		; Increment weight pointer
		iny
		cpy #$00
		bne +
		inc weight_pointer_h
		+

		lda divideweight_weight+1
		sta (weight_pointer_l), y

		; Increment weight pointer
		iny
		cpy #$00
		bne ++
		inc weight_pointer_h
		++

		dec neuron_input_counter
		lda neuron_input_counter
		;sta $0070
		cmp #$00
		bne @input_loop
	
	lda #$00
	sta (weight_pointer_l), y

	; Increment weight pointer
	iny
	cpy #$00
	bne +++
	inc weight_pointer_h
	+++

	lda #$00
	sta (weight_pointer_l), y

	; Increment weight pointer
	iny
	cpy #$00
	bne ++++
	inc weight_pointer_h
	++++
		
	rts

