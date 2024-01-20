; Divides weight by current layer size
.enum SubroutineArgs
	divideweight_weight			.dsb 2
	divideweight_prev_neurons 	.dsb 1
.ende
DivideWeight:
	@shift_loop:
		clc
		ror divideweight_weight+1
		ror divideweight_weight

		dec divideweight_prev_neurons
		bne @shift_loop
	rts
