;----------------------------------------------------------------
; Constants
;----------------------------------------------------------------

;----------------------------------------------------------------
; Memory Map of NES
;----------------------------------------------------------------
;
;   $0000-$00FF :   Zero-page RAM
;   $0100-$01FF :   Stack
;   $0200-$07FF :   Internal RAM
;   ---------------------------------------
;   $0800-$0FFF
;   $1000-$17FF :   Mirrors of $0000-$07FF
;   $1800-$1FFF
;   --------------------------------------
;   $2000-$2007 :   PPU registers
;   $2008-$3FFF :   Mirrors of $2000-$2007
;   $4000-$4017 :   APU and I/O registers
;   $4020-$FFFF :   Cartridge space

;----------------------------------------------------------------
; variables
;----------------------------------------------------------------
pointer_l = $0000
pointer_h = $0001

.enum $0002
    SubroutineArgs .dsb 16
.ende

;----------------------------------------------------------------
; iNES header
;----------------------------------------------------------------

    .org $7FF0
Header:
	.db "NES", $1a  ;identification of the iNES header
	.db $02         ; 32KB PRG (2x 16KB banks)
    .db $01         ; 8KB CHR (1x 8KB bank)
    .db $00         ; mapper 0 NROM
    .db $00         ; mapper 0
    .db $00
    .db $00
    .db $00
    .db $00
    .db $00
    .db $00
    .db $00
    .db $00

;----------------------------------------------------------------
; Code start
;----------------------------------------------------------------

	.org $8000

Reset:
    LDX #$02        ; Load 2 into X register as counter
WarmUp:
    BIT $2002
    BPL WarmUp
    DEX
    BNE WarmUp      ; Loop until X=0

    SEI             ; Disable interrupt requests (IRQs)
    CLD             ; Disable decimal mode
    LDX #$00
    STX $2000       ; Disable NMI
    STX $2001       ; Disable sprites/background
    DEX             ; X=$FF
    TXS             ; Send $FF to stack pointer
    LDA #$00        ; A=0
    TAX
ClearRAM:
    STA $0000, x    ; Set all RAM to zero
    STA $0100, x
    STA $0200, x
    STA $0300, x
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x

    INX
    BNE ClearRAM    ; Finish clearing when X overflows

    LDX #$03        ; X=3 loop
Boot:
    BIT $2002
    BPL Boot
    DEX
    BNE Boot

;----------------------------------------------------------------
; Setup
;----------------------------------------------------------------

LoadPalette:
    LDA #$3F            ; Set PPU write address to $3F00
    STA $2006
    LDX #$00
    STX $2006

PaletteLoop:
    LDA Palette, x      ; Load palette colours to PPU $3F00
    STA $2007
    INX
    CMP #$10            ; Write 32 times
    BNE PaletteLoop

LoadBackground:
    LDA #<Background    ; Load low byte of background
    STA pointer_l
    LDA #>Background    ; Load high byte of background
    STA pointer_h

    LDA $2002           ; Clear high/low latch
    LDA #$20            ; Load high byte of screen address
    STA $2006           ; Set PPU write address
    LDY #$00            ; Load low byte of screen address
    STY $2006

    LDX #$04
    CLC

BackgroundLoop:
    LDA (pointer_l), y
    STA $2007
    INY
    CPY #$00            ; Check overflow
    BNE BackgroundLoop
    INC pointer_h
    DEX
    CPX #$00
    BNE BackgroundLoop

Exit:
    LDA #%10001000      ; Turn on NMI
    STA $2000
    LDA #%00011110      ; Turn on screen
    STA $2001

    LDA #$00
    STA $2005           ; PPU scroll X
    STA $2005           ; PPU scroll Y

    LDY #$00

;----------------------------------------------------------------
; Main Loop
;----------------------------------------------------------------
Loop:
    LDA #$02
    STA addfixed_num_A+1
    LDA #$00
    STA addfixed_num_A
    LDA #$03
    STA addfixed_num_B+1
    LDA #$00
    STA addfixed_num_B
    JSR AddFixed
    LDA addfixed_num_A
    STA $0020
    LDA addfixed_num_A+1
    STA $0021
    JMP Loop

;----------------------------------------------------------------
; Subroutines
;----------------------------------------------------------------
.include "./src/subroutines/AddFixed.asm"

;----------------------------------------------------------------
; Interrupts
;----------------------------------------------------------------

NMI:
    PHA
    TXA
    PHA
    TYA
    PHA                 ; Backup A, B and Y to the stack

    LDX #$00
    STX $2001           ; Disable sprites/background

    LDA $2002           ; Clear high/low latch
    LDA #$20            ; Load high byte of screen address
    STA $2006           ; Set PPU write address
    LDY #$50            ; Load low byte of screen address
    STY $2006

    LDA #%10001000  ; Turn on NMI
    STA $2000
    LDA #%00011110  ; Turn on screen
    STA $2001
    LDA #$00        ; Tell the PPU there is no background scrolling
    STA $2005
    STA $2005

    PLA
    TYA
    PLA
    TXA
    PLA             ; Restore A, X and Y from the stack

    RTI

IRQ:
    RTI

;----------------------------------------------------------------
; Included files
;----------------------------------------------------------------

Palette:
    .incbin "./assets/palette.dat"

Background:
    .include "./assets/background.asm"

Attribute:
    .include "./assets/attribute.asm"

Sprites:
    ; y - tile - attributes - x
    ; Attributes: flipV flipH priority x x x palette palette
    .db $FE,$FE,$FE,$FE     ; zero sprite

;----------------------------------------------------------------
; Constants
;----------------------------------------------------------------

;----------------------------------------------------------------
; Vectors
;----------------------------------------------------------------

    .org $FFFA
    .dw NMI
    .dw Reset
    .dw IRQ

;----------------------------------------------------------------
; CHR-ROM bank
;----------------------------------------------------------------

	.incbin "./assets/background.chr"
    .incbin "./assets/sprites.chr"