
mainplayer_position:
	.word 100
	.byte 144

mainplayer_main_anim:
	.byte FRAME_MAIN_FLY_START
mainplayer_main_anim_counter:
	.byte 7

mainplayer_anim_speed:
	.byte 7

_mainplayer_was_hit:
	.byte -1

_mainplayer_moves_y:
	.byte 0

_mainplayer_current_background_pos:
	.word 0

mainplayer_prepareNewStage:
	lda #100
	sta mainplayer_position
	lda #0
	sta mainplayer_position + 1
	sta _mainplayer_moves_y
	sta _mainplayer_current_background_pos
	sta _mainplayer_current_background_pos + 1
	lda #144
	sta mainplayer_position + 2
	
	rts
	

//################################################
//
//	Check to see if main has fired
//
//################################################

mainplayer_checkFireButton:

	lda _input_fast_fire_repeat
	bne mainplayer_nfb01

/*
	lda mainplayer_position
	sec
	sbc #16
	sta mainplayer_fire_x
	lda mainplayer_position + 1
	sbc #0
	sta mainplayer_fire_x + 1
	lda mainplayer_position + 2
	sec
	sbc #2
	sta mainplayer_fire_y
	jsr mainplayer_fire
*/
	lda mainplayer_position
	clc
	adc #16
	sta mainplayer_fire_x
	lda mainplayer_position + 1
	adc #0
	sta mainplayer_fire_x + 1
	lda mainplayer_position + 2
	clc
	adc #11
	sta mainplayer_fire_y
	jsr mainplayer_fire
	
mainplayer_nfb01:	
	rts

mainplayer_fire_x:
	.word 0
mainplayer_fire_y:
	.byte 0
	
mainplayer_fire:

	ldx mainplayer_fire_x
	ldy mainplayer_fire_x + 1
	lda mainplayer_fire_y
	jsr utilites_spritepos2charXY
	beq mainplayer_mpf01 // error
	ldx $fb
	stx _mainplayer_current_background_pos
	ldy $fc
	sty _mainplayer_current_background_pos + 1
	jmp mainbullet_add
mainplayer_mpf01:	
	rts	
	

//
//
//
mainplayer_checkMovement:

	lda #7
	sta mainplayer_anim_speed

	// Collide with background due to scroll?
	lda _scroll_happened_this_frame
	beq mainplayer_cmv21
	jsr mainplayer_checkBackgroundCollision
	bcc mainplayer_cmv21
	:sub16 #2;mainplayer_position
mainplayer_cmv21:	

	lda _input_joy_pressed + JOY_UP
	bne mainplayer_nu01
	:set(_mainplayer_moves_y)
	lda #1
	sta mainplayer_anim_speed
mainplayer_nu01:

	lda _input_joy_pressed + JOY_DOWN
	bne mainplayer_nd01
	lda #2
	sta _mainplayer_moves_y
	lda #15
	sta mainplayer_anim_speed
mainplayer_nd01:

	lda mainplayer_position + 1
	bne mainplayer_nl03
	lda mainplayer_position
	cmp #MAIN_BORDER_LEFT
	beq mainplayer_nl01
mainplayer_nl03:
	lda _input_joy_pressed + JOY_LEFT
	bne mainplayer_nl01
	:sub16 #2;mainplayer_position
	jsr mainplayer_checkBackgroundCollision
	bcc mainplayer_nl02
	:add16 #2;mainplayer_position
mainplayer_nl02:	
	lda #3
	sta mainplayer_anim_speed
mainplayer_nl01:

	lda mainplayer_position + 1
	beq mainplayer_nr03
	lda mainplayer_position
	cmp #MAIN_BORDER_RIGHT
	beq mainplayer_nr01
mainplayer_nr03:
	lda _input_joy_pressed + JOY_RIGHT
	bne mainplayer_nr01
	:add16 #2;mainplayer_position
	jsr mainplayer_checkBackgroundCollision
	bcc mainplayer_nr02
	:sub16 #2;mainplayer_position
mainplayer_nr02:	
	lda #3
	sta mainplayer_anim_speed
mainplayer_nr01:

	lda _mainplayer_moves_y
	beq mainplayer_dmy01

	cmp #1
	bne mainplayer_dmy02
	lda mainplayer_position + 2
	cmp #MAIN_BORDER_UP
	beq mainplayer_dmy01
	:sub8 #2;mainplayer_position + 2
	jsr mainplayer_checkBackgroundCollision
	bcc mainplayer_dmy03
	:add8 #2;mainplayer_position + 2
	lda #0
	sta _mainplayer_moves_y
mainplayer_dmy03:	
	lda mainplayer_position + 2
	and #7
	bne mainplayer_dmy01
	lda #0
	sta _mainplayer_moves_y
	jmp mainplayer_dmy01

mainplayer_dmy02:
	lda mainplayer_position + 2
	cmp #MAIN_BORDER_DOWN
	beq mainplayer_dmy01
	:add8 #2;mainplayer_position + 2
	jsr mainplayer_checkBackgroundCollision
	bcc mainplayer_dmy04
	:sub8 #2;mainplayer_position + 2
	lda #0
	sta _mainplayer_moves_y
mainplayer_dmy04:	
	lda mainplayer_position + 2
	and #7
	bne mainplayer_dmy01
	lda #0
	sta _mainplayer_moves_y
	
mainplayer_dmy01:


	lda mainplayer_position
	sta SPRITE_ZERO_PAGE_X_COORD
	lda mainplayer_position + 1
	sta SPRITE_ZERO_PAGE_X_MSB_COORD

	lda mainplayer_position + 2
	sta SPRITE_ZERO_PAGE_Y_COORD
	lda mainplayer_main_anim
	sta SPRITE_ZERO_PAGE_FRAME

	lda #3
	sta SPRITE_ZERO_PAGE_COLOR
	jsr smux_drawSprite

	inc mainplayer_main_anim_counter
	lda mainplayer_main_anim_counter
	and mainplayer_anim_speed
	bne mainplayer_na01

	inc mainplayer_main_anim
	lda mainplayer_main_anim
	cmp #FRAME_MAIN_FLY_END
	bne mainplayer_na01
	lda #FRAME_MAIN_FLY_START
	sta mainplayer_main_anim
mainplayer_na01:
	rts
	
	
//##############################################
//
// Check to see if main has hit a wall
//
//##############################################

// TODO: MAKE THIS FASTER!!! FFS!!
mainplayer_checkBackgroundCollision:

	lda mainplayer_position		// x lsb
	clc
	adc #16
	tax
	lda mainplayer_position + 1 // x msb
	adc #0
	tay
	lda mainplayer_position + 2 // y
	clc
	adc #11
	jsr utilites_spritepos2charXY
	bne mainplayer_cbc02 // error
	rts
mainplayer_cbc02:	
	ldx $fb
	stx _mainplayer_current_background_pos
	ldy $fc
	sty _mainplayer_current_background_pos + 1

	lda _mainplayer_current_background_pos + 1
	asl
	tay
	lda tables_screen_row, y
	clc
	adc _irq_screen_mem_front
	sta $fa
	lda tables_screen_row + 1, y
	adc _irq_screen_mem_front + 1
	sta $fb

	ldy _mainplayer_current_background_pos
	lda ($fa), y
	and #%11111100
	beq mainplayer_cbc01
	sec
	rts
mainplayer_cbc01:	
	clc
	rts	
	
