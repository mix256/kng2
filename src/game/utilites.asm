
utilities_s2c_err:
	.byte 0

//
// IN:		X/Y = X-pos
//			A = Y-Pos
// OUT:		$fb=x (0=err); $fc=y
//
utilites_spritepos2charXY:
	sec
	sbc #50
	bcc utilities_yOutside
	lsr
	lsr
	lsr
	sta $fc
	txa
	lsr
	lsr
	lsr
	cpy #0
	beq utilities_sp2c01
	clc
	adc #32
utilities_sp2c01:
	sec
	sbc #3
	bcc utilities_xOutside
	sta $fb
	rts

utilities_yOutside:
utilities_xOutside:
	:clear($fb)
	rts
