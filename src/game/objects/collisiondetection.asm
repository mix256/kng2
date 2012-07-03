

_collision_detection_bit:	// Current check (main or mainbullet)
	.byte 0

collisiondetection_objectsVersusMain:

	lda #COLLISION_WITH_MAIN
	sta _collision_detection_bit

	lda mainplayer_position
	sta COLLISION_ZERO_PAGE_A_X1
	clc
	adc #MAIN_SPRITE_WIDTH
	sta COLLISION_ZERO_PAGE_A_X2
	lda mainplayer_position + 1
	sta COLLISION_ZERO_PAGE_A_X1_MSB
	adc #0
	sta COLLISION_ZERO_PAGE_A_X2_MSB
	lda mainplayer_position + 2
	sta COLLISION_ZERO_PAGE_A_Y1
	clc
	adc #MAIN_SPRITE_HEIGHT
	sta COLLISION_ZERO_PAGE_A_Y2

	jsr collisiondetection_checkCollision
	stx _mainplayer_was_hit
	rts



collisiondetection_objectsVersusMainbullets:

	lda #COLLISION_WITH_MAINBULLET
	sta _collision_detection_bit

	ldy #0
collisiondetection_ovmb02:
	lda _mainbullet_bullet_pos, y
	beq collisiondetection_ovmb01
	lda _mainbullet_bullet_pos + 1, y
	tax
	lda tables_char_row_to_sprite_y, x
	sta COLLISION_ZERO_PAGE_A_Y1
	clc
	adc #8
	sta COLLISION_ZERO_PAGE_A_Y2

	lda _mainbullet_bullet_pos, y
	asl
	tax
	lda tables_char_col_to_sprite_x, x
	sta COLLISION_ZERO_PAGE_A_X1
	clc
	adc #16
	sta COLLISION_ZERO_PAGE_A_X2
	lda tables_char_col_to_sprite_x + 1, x
	sta COLLISION_ZERO_PAGE_A_X1_MSB
	adc #0
	sta COLLISION_ZERO_PAGE_A_X2_MSB

	jsr collisiondetection_checkCollision
	cpx #-1
	beq	collisiondetection_ovmb01
	// Clear mainbullet by setting a zero ontop of it...

	lda _mainbullet_bullet_pos + 1, y
	asl
	tax
	lda tables_screen_row, x
	clc
	adc _irq_screen_mem_front
	sta COLLISION_ZERO_PAGE_A_X1
	lda tables_screen_row + 1, x
	adc _irq_screen_mem_front + 1
	sta COLLISION_ZERO_PAGE_A_X1_MSB

	sty _tmp_1
	lda _mainbullet_bullet_pos, y
	tay
	lda #0
	sta (COLLISION_ZERO_PAGE_A_X1), y
	ldy _tmp_1
collisiondetection_ovmb01:
	iny
	iny
	cpy #MAX_NO_MAINBULLETS
	bne collisiondetection_ovmb02
	rts

//##################################################
//
// IN: 	COLLISION_ZERO_PAGE_A_X1...COLLISION_ZERO_PAGE_A_Y2
// OUT: X = object that collided, -1 if none
//
//##################################################

collisiondetection_checkCollision:
	ldx #0
collisiondetection_ovs02:
	lda _objectarray_type, x
	beq collisiondetection_ovs01
	lda _objectarray_collisionType, x
	and _collision_detection_bit
	beq collisiondetection_ovs01

	lda _objectarray_x_coord, x
	sta COLLISION_ZERO_PAGE_B_X1
	clc
	adc _objectarray_width, x
	sta COLLISION_ZERO_PAGE_B_X2
	lda _objectarray_x_msb_coord, x
	sta COLLISION_ZERO_PAGE_B_X1_MSB
	adc #0
	sta COLLISION_ZERO_PAGE_B_X2_MSB

.pc = * "comparetest"
	:compare16 COLLISION_ZERO_PAGE_B_X2;COLLISION_ZERO_PAGE_A_X1
	bne collisiondetection_ovs01
	:compare16 COLLISION_ZERO_PAGE_A_X2;COLLISION_ZERO_PAGE_B_X1
	bne collisiondetection_ovs01

	lda _objectarray_y_coord, x
	sta COLLISION_ZERO_PAGE_B_Y1
	clc
	adc _objectarray_height, x
	sta COLLISION_ZERO_PAGE_B_Y2

	:compare8 COLLISION_ZERO_PAGE_B_Y2;COLLISION_ZERO_PAGE_A_Y1
	bcc collisiondetection_ovs01
	:compare8 COLLISION_ZERO_PAGE_A_Y2;COLLISION_ZERO_PAGE_B_Y1
	bcc collisiondetection_ovs01

	// Hit
	lda #1
	sta _objectarray_was_hit, x
	rts

collisiondetection_ovs01:
	inx
	cpx #NUMBER_OF_OBJECTS
	bne collisiondetection_ovs02
	ldx #-1
	rts


