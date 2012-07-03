
//.const LIZ_START_FRAME = FRAME_ENEMIES_START + 7
//.const LIZ_END_FRAME = FRAME_ENEMIES_START + 11
.const LIZ_START_FRAME = FRAME_MAIN_START + 0
.const LIZ_END_FRAME = FRAME_MAIN_START + 7

liz_routines:
	jmp liz_create
	jmp liz_update
	jmp liz_dead
	jmp liz_draw

liz_create:
	lda #COLLISION_WITH_MAIN + COLLISION_WITH_MAINBULLET
	sta _objectarray_collisionType, x

	lda #1
	sta _objectarray_hits, x

	lda #24
	sta _objectarray_width, x
	lda #21
	sta _objectarray_height, x

	lda #ANIMATION_TYPE_LOOP
	sta _animation_type, x
	lda #LIZ_START_FRAME
	sta _animation_start_frame, x
	lda #LIZ_END_FRAME
	sta _animation_end_frame, x
	lda #6
	sta _animation_speed, x
	jsr animation_setAnimation
	rts

_liz_movetab:
	.byte 1,2,3,4,3,2,1,0
	.byte -1,-2,-3,-4,-3,-2,-1,0	

liz_update:
	// Hit (TODO: Change)
	lda _objectarray_was_hit, x
	beq liz_u01
	dec _objectarray_hits, x
liz_u01:
	lda _objectarray_hits, x
	beq liz_dead

	// Check clipping
	jsr objectroutines_clipObject

	// Move
	jsr objectroutines_scrollObject
	
	:moveObject #-1;_objectarray_x_coord, x
	
	lda _objectarray_user_properties + [NUMBER_OF_OBJECTS * 0], x
	clc
	adc #1
	sta _objectarray_user_properties + [NUMBER_OF_OBJECTS * 0], x
	and #63
	lsr
	lsr
	tay
	lda _liz_movetab, y
	clc
	adc _objectarray_y_coord, x
	sta _objectarray_y_coord, x

	// Animate
	jsr animation_updateFrame

	// Check if to fire
	lda _objectarray_user_properties + [NUMBER_OF_OBJECTS * 1], x
	clc
	adc #1
	sta _objectarray_user_properties + [NUMBER_OF_OBJECTS * 1], x
	and #63
	bne liz_u02
	jsr liz_fire
liz_u02:

	// Draw
	jsr liz_draw
	
	rts

liz_draw:
	jsr objectroutines_drawObject
	rts

liz_dead:
	txa
	pha

	lda #OBJECT_PHOENIX
//	lda #OBJECT_EXPLOSION
	sta OBJECT_ZERO_PAGE_TYPE
	lda _objectarray_x_coord, x
	sta OBJECT_ZERO_PAGE_X_COORD
	lda _objectarray_x_msb_coord, x
	sta OBJECT_ZERO_PAGE_X_MSB_COORD
	lda _objectarray_y_coord, x
	sta OBJECT_ZERO_PAGE_Y_COORD
	lda #10
	sta OBJECT_ZERO_PAGE_COLOR
	jsr objectroutines_createObject

	pla
	tax

	lda #OBJECT_NONE
	sta _objectarray_type, x
	rts

liz_fire:
	txa
	pha

	lda #OBJECT_ENEMYBULLET
	sta OBJECT_ZERO_PAGE_TYPE
	lda _objectarray_x_coord, x
	sta OBJECT_ZERO_PAGE_X_COORD
	lda _objectarray_x_msb_coord, x
	sta OBJECT_ZERO_PAGE_X_MSB_COORD
	lda _objectarray_y_coord, x
	sta OBJECT_ZERO_PAGE_Y_COORD
	lda #10
	sta OBJECT_ZERO_PAGE_COLOR
	
	lda mainplayer_position
	sec
	sbc OBJECT_ZERO_PAGE_X_COORD
	sta OBJECT_ZERO_PAGE_PROPERTY_1

	lda mainplayer_position + 2
	sec
	sbc OBJECT_ZERO_PAGE_Y_COORD
	sta OBJECT_ZERO_PAGE_PROPERTY_2

	jsr objectroutines_createObject

	pla
	tax

	rts
