; Adds two fixed point numbers and returns the result in num_A
.enum SubroutineArgs
    addfixed_A .dsb 2        ; First fixed number
    addfixed_B .dsb 2        ; Second fixed number
.ende
AddFixed:
    CLC
    LDA addfixed_A
    ADC addfixed_B
    STA addfixed_A
    LDA addfixed_A+1
    ADC addfixed_B+1
    STA addfixed_A+1

    RTS
