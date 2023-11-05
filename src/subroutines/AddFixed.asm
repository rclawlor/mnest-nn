; Adds two fixed point numbers and returns the result in num_A
.enum SubroutineArgs
    addfixed_num_A .dsb 2        ; First fixed number
    addfixed_num_B .dsb 2        ; Second fixed number
.ende
AddFixed:
    CLC
    LDA addfixed_num_A+1
    ADC addfixed_num_B+1
    STA addfixed_num_A+1
    LDA addfixed_num_A
    ADC addfixed_num_B
    STA addfixed_num_A

    RTS
