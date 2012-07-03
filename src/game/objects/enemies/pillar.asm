
pillar_routines:
	jmp pillar_create
	jmp pillar_update
	jmp pillar_dead
	jmp pillar_draw

pillar_create:
	lda #COLLISION_WITH_MAIN + COLLISION_WITH_MAINBULLET
	sta _objectarray_collisionType, x

	lda #15
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
	lda #FRAME_ENEMIES_START + 0
	sta _animation_current_frame, x
	
	lda #2
	sta _objectarray_user_properties,x
	rts


pillar_update:
	// Hit (TODO: Change)
	lda _objectarray_was_hit, x
	beq pillar_u01
	dec _objectarray_hits, x
	lda _objectarray_hits, x
	beq pillar_dead
	jmp pillar_u03
pillar_u01:

	// Check clipping
	jsr objectroutines_clipObject

	// Move
	:moveObject8 _objectarray_user_properties,x;_objectarray_y_coord,x
	cmp #182
	bne pillar_u02	
	lda #-2
	sta _objectarray_user_properties,x
	jmp pillar_u03
pillar_u02:
	cmp #98
	bne pillar_u03	
	lda #2
	sta _objectarray_user_properties,x	
pillar_u03:

	jsr objectroutines_scrollObject

	// Animate
//	jsr animation_updateFrame

	// Draw
	jsr pillar_draw
	rts

pillar_draw:
	jsr objectroutines_drawObject
	rts

pillar_dead:
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

