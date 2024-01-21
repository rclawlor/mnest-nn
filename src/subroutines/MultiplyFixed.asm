; Credit to The Merlin 128 Macro Assembler disk, via 'The Fridge': http://www.ffd2.com/fridge/math/mult-div.s
; with an optimisation for speed (changing pha/pla to tax/txa) by https://github.com/TobyLobster
;
; 16 bit x 16 bit unsigned multiply, 32 bit result
; Average cycles: 578
; 33 bytes


; acc*aux -> [acc,acc+1,ext,ext+1] (low,hi) 32 bit result

; aux = $02       ; 2 bytes   input1
; acc = $04       ; 2 bytes   input2   } result
; ext = $06       ; 2 bytes            }

; * = $0200
.enum SubroutineArgs
    multiplyfixed_A .dsb 2        	; First fixed number
    multiplyfixed_B .dsb 2        	; Second fixed number
	multiplyfixed_C .dsb 2			; Third fixed number
.ende
MultiplyFixed:
	; Push X and Y to stack
	TXA
	PHA
	TYA
	PHA
; (acc, acc+1, ext, ext+1) = (aux, aux+1) * (acc, acc+1)
    LDA #0                          ; A holds the low byte of ext (zero for now)
    STA multiplyfixed_C+1           ; high byte of ext = 0
    LDY #17                         ; loop counter. Loop 17 times.
    CLC                             ;
@Loop:
    ROR multiplyfixed_C+1           ; }
    ROR                             ; }
    ROR multiplyfixed_B+1           ; } acc_ext >> 1
    ROR multiplyfixed_B             ; }
    BCC @Multiply2                  ; skip if carry clear

    CLC                             ;               }
    ADC multiplyfixed_A             ;               }
    TAX                             ; remember A    }
    LDA multiplyfixed_A+1           ;               } ext += aux
    ADC multiplyfixed_C+1           ;               }
    STA multiplyfixed_C+1           ;               }
    TXA                             ; recall A
@Multiply2:
    DEY                             ; decrement loop counter
    BNE @Loop                       ; loop back if not done yet

    STA multiplyfixed_C             ;

	; Restore X and Y
	PLA
	TAY
	PLA
	TAX

    RTS                             ;
