
font_copyCharacterData:
	ldx #0
font_cdt01:	
	lda _font_font16, x
	sta $c400, x
	lda _font_font16 + $0100, x
	sta $c500, x
	lda _font_font16 + $0200, x
	sta $c600, x
	lda _font_font16 + $0300, x
	sta $c700, x
	inx
	bne font_cdt01
	rts

font_clearScreen:
	ldx #0
	lda #128
font_cs01:	
	sta $c000, x
	sta $c100, x
	sta $c200, x
	sta $c300, x
	inx
	bne font_cs01
	rts

font_setFontColors:
	ldx #0
font_sfc01:	
	lda #1
	sta _nmi_split_bkgcolor_tab + 4, x
	lda #11
	sta _nmi_split_multicolor_tab_m1 + 4, x
	lda #15
	sta _nmi_split_multicolor_tab_m2 + 4, x
	inx
	cpx #8
	bne font_sfc01
	rts
	
font_setupFontScreen:
	jsr font_clearScreen
	jsr font_copyCharacterData
	
	:waitVBlank()
	jsr font_setFontColors
	lda #%00000000
	sta _irq_d018_front
	rts

font_drawText:
font_dt03:	
	ldy #0
	lda ($fa), y
	beq font_dt01
	cmp #32
	beq font_dt04
	jsr font_drawChar
font_dt04:	
	:add16 #1;$fa
	:add16 #2;$fc
	jmp font_dt03
font_dt01:
	rts
	
font_drawChar:
//	ldy #0
//	lda ($fa), y
	asl
	asl
	clc
	adc #129
	tax
	sta ($fc), y
	clc
	adc #2
	iny
	sta ($fc), y
	tya
	clc
	adc #39
	tay
	inx
	txa
	sta ($fc), y
	clc
	adc #2
	iny
	sta ($fc), y
	rts
	
_font_font16:
	.fill 40, 0
	.import binary "resources/graphics/generated/fonts/font16.bin"
	