/*
($d800+ is almost always black. No need to change at fadeOut to black or fadeIn from black)
# sprites
# _nmi_split_bkgcolor_tab + 4, 9st:
# _nmi_split_multicolor_tab_m1 + 4, 9st:
# _nmi_split_multicolor_tab_m2 + 4, 9st:
*/

_transitions_fadeout_to_black_table:
	.byte $0,$f,$0,$e,$6,$0,$0,$8,$9,$0,$2,$0,$b,$5,$6,$c

_transitions_fadeout_to_white_table:
	.byte $b,$f,$a,$1,$a,$d,$e,$1,$7,$8,$f,$c,$f,$1,$3,$1

_transitions_fadein_from_black_table:
	.byte $0,$b,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.byte $0,$c,$0,$6,$6,$0,$0,$9,$0,$0,$0,$0,$0,$0,$6,$b
	.byte $0,$f,$2,$e,$4,$5,$6,$8,$9,$9,$2,$b,$b,$5,$3,$c
	.byte $0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$a,$b,$c,$d,$e,$f

_transitions_fadein_from_white_table:
	.byte $f,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1,$1
	.byte $c,$1,$f,$1,$1,$3,$3,$1,$1,$7,$1,$f,$1,$1,$1,$1
	.byte $b,$1,$a,$3,$f,$d,$e,$7,$7,$8,$f,$c,$f,$3,$3,$1
	.byte $0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$a,$b,$c,$d,$e,$f

_transitions_fadein_counter: // (0,16,32,48)
	.byte 0

_transitions_fade_in_progress:
	.byte 0

_transitions_fade_speed_counter:
	.byte 10

_transitions_fadein_colors:
	.byte 8, 9, 8, 7, 1, 7, 8, 9, 8
	.byte 7, 1, 7, 8, 9, 8, 7, 1, 7
	.byte 12,11,12,15,1,15,12,11,12
	.byte 11, 1
	.fill NUMBER_OF_SMUX_SPRITES, $e


// Speed used by all fades/fade-inits except bar-types
_transitions_fade_speed:
	.byte 3

_transitions_bar_pos:
	.byte 0

_transitions_type:
	.byte 0

//------------------------------------
// TransitionRunner (locked mode)
//------------------------------------
// TODO: Now only for fade out to black...

transition_transitionRunnerLock:

transitions_tr02l:
	lda _transitions_fade_in_progress
	beq transitions_tr01l
	
	jsr irq_waitForNewFrame
	jsr transitions_fadeOutToBlack
	jsr irq_frameDone
	jmp transitions_tr02l
transitions_tr01l:

	rts
	

//------------------------------------
// TransitionRunner
//------------------------------------

transition_transitionRunner:

	lda _transitions_fade_in_progress
	beq transitions_tr01

	lda _transitions_type
	beq transitions_tr01
	cmp #TRANSITION_FADEOUT_BLACK
	bne transitions_tr02
	jmp transitions_fadeOutToBlack
transitions_tr02:
	cmp #TRANSITION_FADEBAR_WHITE
	bne transitions_tr03
	jmp transitions_fadeBarToWhite
transitions_tr03:
	cmp #TRANSITION_FADEIN_BLACK
	bne transitions_tr04
	jmp transitions_fadeInFromBlack
transitions_tr04:


transitions_tr01:
	rts


//------------------------------------
// Fadein from black init
//------------------------------------
transitions_fadeInFromBlack_init:
	lda _transitions_fade_speed
	sta _transitions_fade_speed_counter
	lda #4
	sta _transitions_fade_in_progress
	lda #TRANSITION_FADEIN_BLACK
	sta _transitions_type
	:clear(_transitions_fadein_counter)
	rts

//------------------------------------
// Fadein from black
//------------------------------------
transitions_fadeInFromBlack:
	dec _transitions_fade_speed_counter
	lda _transitions_fade_speed_counter
	bmi transitions_fifb02
	rts
transitions_fifb02:
	lda _transitions_fade_speed
	sta _transitions_fade_speed_counter

	ldx #0
transitions_fifb01:
	lda _transitions_fadein_colors, x
	clc
	adc _transitions_fadein_counter
	tay
	lda _transitions_fadein_from_black_table, y
	sta _nmi_split_bkgcolor_tab + 4, x

	lda _transitions_fadein_colors + 9, x
	clc
	adc _transitions_fadein_counter
	tay
	lda _transitions_fadein_from_black_table, y
	sta _nmi_split_multicolor_tab_m1 + 4, x

	lda _transitions_fadein_colors + 18, x
	clc
	adc _transitions_fadein_counter
	tay
	lda _transitions_fadein_from_black_table, y
	sta _nmi_split_multicolor_tab_m2 + 4, x
	inx
	cpx #9
	bne transitions_fifb01

	lda _transitions_fadein_colors + 27
	clc
	adc _transitions_fadein_counter
	tay
	lda _transitions_fadein_from_black_table, y
	sta $d025

	lda _transitions_fadein_colors + 28
	clc
	adc _transitions_fadein_counter
	tay
	lda _transitions_fadein_from_black_table, y
	sta $d026

	// TODO: FIX THIS! Doesn't really work. $d027 is sat in IRQ/SMUX
	ldy #16
	lda _irq_sprite_front_buffer
	beq transitions_fifb03l
	ldy #0
transitions_fifb03l:

	ldx #0
transitions_fifb03:
	lda _transitions_fadein_colors + 29, x
	clc
	adc _transitions_fadein_counter
	tay
	lda _transitions_fadein_from_black_table, y
	sta _smux_sprite_buffer_color, y
	inx
	iny
	cpx #NUMBER_OF_SMUX_SPRITES
	bne transitions_fifb03

	lda _transitions_fadein_counter
	clc
	adc #16
	sta _transitions_fadein_counter

	dec _transitions_fade_in_progress

	rts


//------------------------------------
// Fadeout to black init
//------------------------------------

transitions_fadeOutToBlack_init:
	lda _transitions_fade_speed
	sta _transitions_fade_speed_counter
	lda #4
	sta _transitions_fade_in_progress
	lda #TRANSITION_FADEOUT_BLACK
	sta _transitions_type
	rts

//------------------------------------
// Fadeout to black
//------------------------------------
transitions_fadeOutToBlack:
	dec _transitions_fade_speed_counter
	lda _transitions_fade_speed_counter
	bmi transitions_fotb02
transitions_fotb03:
	rts
transitions_fotb02:
	lda _transitions_fade_speed
	sta _transitions_fade_speed_counter

	ldx #0
	ldy #9
transitions_fotb01:
	sty _tmp_1

	// Background
	lda _nmi_split_bkgcolor_tab + 4, x
	tay
	lda _transitions_fadeout_to_black_table, y
	sta _nmi_split_bkgcolor_tab + 4, x

	lda _nmi_split_multicolor_tab_m1 + 4, x
	tay
	lda _transitions_fadeout_to_black_table, y
	sta _nmi_split_multicolor_tab_m1 + 4, x

	lda _nmi_split_multicolor_tab_m2 + 4, x
	tay
	lda _transitions_fadeout_to_black_table, y
	sta _nmi_split_multicolor_tab_m2 + 4, x

	ldy _tmp_1
	inx
	dey
	bne transitions_fotb01

	// Sprites
	lda $d025
	tay
	lda _transitions_fadeout_to_black_table, y
	sta $d025

	lda $d026
	tay
	lda _transitions_fadeout_to_black_table, y
	sta $d026

	// Sprites Mx-Colors (rätt buffer!!!)

	dec _transitions_fade_in_progress

	rts

//------------------------------------
// Set to white
//------------------------------------
transition_setAllColorsToWhite:

	ldx #0
	lda #1
transition_sactw01:
	sta _nmi_split_bkgcolor_tab + 4,x
	sta _nmi_split_multicolor_tab_m1 + 4, x
	sta _nmi_split_multicolor_tab_m2 + 4, x
	inx
	cpx #9
	bne transition_sactw01
	sta $d025
	sta $d026
	rts

//------------------------------------
// Clear Frontbuffer (done before blackoutfade from white)
//------------------------------------
transition_clearBothBuffers:
	ldx #0
transition_cfb01:
	lda #1
	sta SCREEN_FRONT_BUFFER, x
	sta SCREEN_FRONT_BUFFER + $0100, x
	sta SCREEN_FRONT_BUFFER + $0200, x
	sta SCREEN_FRONT_BUFFER + $0300, x
	sta SCREEN_BACK_BUFFER, x
	sta SCREEN_BACK_BUFFER + $0100, x
	sta SCREEN_BACK_BUFFER + $0200, x
	sta SCREEN_BACK_BUFFER + $0300, x
	lda #8
	sta $d800, x
	sta $d900, x
	sta $da00, x
	sta $db00, x
	inx
	bne	transition_cfb01
	rts

//------------------------------------
// Fadebar to white init
//------------------------------------
transitions_fadeBarToWhite_init:
	lda #40
	sta _transitions_fade_in_progress
	:clear(_transitions_bar_pos)
	lda #TRANSITION_FADEBAR_WHITE
	sta _transitions_type
	rts

//------------------------------------
// Fadebar to white
//------------------------------------
transitions_fadeBarToWhite:

	lda _transitions_fade_in_progress
	bne transitions_fbtw_start
	rts
transitions_fbtw_start:
	lda _irq_screen_mem_front
	sta $fa
	lda _irq_screen_mem_front + 1
	sta $fb
	lda #0
	sta $7a
	lda #$d8
	sta $7b

	lda _irq_screen_mem_front
	clc
	adc #239
	sta $fc
	lda _irq_screen_mem_front + 1
	sta $fd
	lda #239
	sta $7c
	lda #$d8
	sta $7d

transitions_fbtwLloop:
	jsr irq_waitForNewFrame

	jsr transitions_drawBarPartLeft
	:add16 #400;$fa
	:add16 #400;$7a
	jsr transitions_drawBarPartLeft
	:add16 #400;$fa
	:add16 #400;$7a
	jsr transitions_drawBarPartLeft
	:sub16 #799;$fa
	:sub16 #799;$7a

	jsr transitions_drawBarPartRight
	:add16 #400;$fc
	:add16 #400;$7c
	jsr transitions_drawBarPartRight
	:sub16 #401;$fc
	:sub16 #401;$7c

	jsr irq_frameDone

	dec _transitions_fade_in_progress
	lda _transitions_fade_in_progress
	beq transitions_fbtwEnd
	jmp transitions_fbtwLloop
transitions_fbtwEnd:
	jsr irq_waitForNewFrame
	jsr transition_setAllColorsToWhite
	jsr irq_waitForNewFrame
	jsr transition_clearBothBuffers
	
	// temp: remove when actually using this
	//jsr transitions_fadeOutToBlack_init
	rts

// Need $fa/$7a sat
transitions_drawBarPartLeft:
	lda #0
	tay
	sta ($fa),y
	lda #9
	sta ($7a),y

	ldy #40
	lda #0
	sta ($fa),y
	lda #9
	sta ($7a),y

	ldy #80
	lda #0
	sta ($fa),y
	lda #9
	sta ($7a),y

	ldy #120
	lda #0
	sta ($fa),y
	lda #9
	sta ($7a),y

	ldy #160
	lda #0
	sta ($fa),y
	lda #9
	sta ($7a),y
	rts

// Need $fc/$7c sat
transitions_drawBarPartRight:
	lda #0
	tay
	sta ($fc),y
	lda #9
	sta ($7c),y

	ldy #40
	lda #0
	sta ($fc),y
	lda #9
	sta ($7c),y

	ldy #80
	lda #0
	sta ($fc),y
	lda #9
	sta ($7c),y

	ldy #120
	lda #0
	sta ($fc),y
	lda #9
	sta ($7c),y

	ldy #160
	lda #0
	sta ($fc),y
	lda #9
	sta ($7c),y
	rts





