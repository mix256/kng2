
bigface_routines:
	jmp bigface_create
	jmp bigface_update
	jmp bigface_dead
	jmp bigface_draw

bigface_create:

	lda #30
	sta scroll_time_to_stop

	lda #COLLISION_WITH_MAIN + COLLISION_WITH_MAINBULLET
	sta _objectarray_collisionType, x

	lda #45
	sta _objectarray_hits, x

	lda #24
	sta _objectarray_width, x
	lda #63
	sta _objectarray_height, x

	lda #ANIMATION_TYPE_NONE
	sta _animation_type, x
	lda #FRAME_ENEMIES_START + 15
	sta _animation_start_frame, x
	lda #FRAME_ENEMIES_START + 15
	sta _animation_end_frame, x
	lda #6
	sta _animation_speed, x
	jsr animation_setAnimation
	rts

bigface_update:
	// Hit (TODO: Change)
	lda _objectarray_was_hit, x
	beq bigface_u01
	dec _objectarray_hits, x
bigface_u01:
	lda _objectarray_hits, x
	beq bigface_dead

	// Check clipping
	jsr objectroutines_clipObject

	// Move
	jsr objectroutines_scrollObject

	// Draw
	jsr bigface_draw
		
	rts

bigface_draw:
	jsr objectroutines_drawObject
	:add8 #21;SPRITE_ZERO_PAGE_Y_COORD
	inc SPRITE_ZERO_PAGE_FRAME
	jsr smux_drawSprite
	:add8 #21;SPRITE_ZERO_PAGE_Y_COORD
	inc SPRITE_ZERO_PAGE_FRAME
	jsr smux_drawSprite
	rts

bigface_dead:
	lda #0
	sta scroll_time_to_stop
	
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
	:add8 #21;OBJECT_ZERO_PAGE_Y_COORD
	jsr objectroutines_createObject
	:add8 #21;OBJECT_ZERO_PAGE_Y_COORD
	jsr objectroutines_createObject
	
	pla
	tax

	lda #OBJECT_NONE
	sta _objectarray_type, x
	rts

