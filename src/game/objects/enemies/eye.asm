
eye_routines:
	jmp eye_create
	jmp eye_update
	jmp eye_dead
	jmp eye_draw

eye_create:

	lda #COLLISION_WITH_MAIN + COLLISION_WITH_MAINBULLET
	sta _objectarray_collisionType, x

	lda #2
	sta _objectarray_hits, x

	lda #24
	sta _objectarray_width, x
	lda #21
	sta _objectarray_height, x
/*
	lda #ANIMATION_TYPE_LOOP
	sta _animation_type, x
	lda #64
	sta _animation_start_frame, x
	lda #72
	sta _animation_end_frame, x
	lda #4
	sta _animation_speed, x
	jsr animation_setAnimation
*/
	lda #FRAME_ENEMIES_START + 1
	sta _animation_current_frame, x
	
	lda #2
	sta _objectarray_user_properties,x
	rts


eye_update:
	// Hit (TODO: Change)
	lda _objectarray_was_hit, x
	beq eye_u01
	dec _objectarray_hits, x
	lda _objectarray_hits, x
	beq eye_dead
eye_u01:

	// Check clipping
	jsr objectroutines_clipObject

	jsr objectroutines_scrollObject

	// Move
	:moveObject #-2;_objectarray_x_coord, x

	// Animate
//	jsr animation_updateFrame

	// Check if to fire
	lda _objectarray_user_properties + [NUMBER_OF_OBJECTS * 1], x
	clc
	adc #1
	sta _objectarray_user_properties + [NUMBER_OF_OBJECTS * 1], x
	and #31
	bne eye_u02
	jsr eye_fire
eye_u02:

	// Draw
	jsr eye_draw
	rts

eye_draw:
	jsr objectroutines_drawObject
	rts

eye_dead:

	txa
	pha

	lda #OBJECT_EXPLOSION
	sta OBJECT_ZERO_PAGE_TYPE
	lda _objectarray_x_coord, x
	sta OBJECT_ZERO_PAGE_X_COORD
	lda _objectarray_x_msb_coord, x
	sta OBJECT_ZERO_PAGE_X_MSB_COORD
	lda _objectarray_y_coord, x
	sta OBJECT_ZERO_PAGE_Y_COORD
	lda #7
	sta OBJECT_ZERO_PAGE_COLOR
	jsr objectroutines_createObject

	pla
	tax

	lda #OBJECT_NONE
	sta _objectarray_type, x
	rts

eye_fire:
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
