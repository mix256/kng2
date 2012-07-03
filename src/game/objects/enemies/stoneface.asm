
stoneface_routines:
	jmp stoneface_create
	jmp stoneface_update
	jmp stoneface_dead
	jmp stoneface_draw

stoneface_create:
	lda #COLLISION_WITH_MAIN + COLLISION_WITH_MAINBULLET
	sta _objectarray_collisionType, x

	lda #40
	sta _objectarray_hits, x

	lda #36
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

	rts


stoneface_update:
	// Hit (TODO: Change)
	lda _objectarray_was_hit, x
	beq stoneface_u01
	dec _objectarray_hits, x
	:moveObject #1;_objectarray_x_coord,x
stoneface_u01:
	lda _objectarray_hits, x
	beq stoneface_dead

	// Check clipping
	jsr objectroutines_clipObject

	// Move
	jsr objectroutines_scrollObject
	:moveObject #-1;_objectarray_x_coord,x

	// Animate
//	jsr animation_updateFrame

	// Draw
	jsr stoneface_draw
	rts

stoneface_draw:
	jsr objectroutines_drawObject
	:add16 #24;SPRITE_ZERO_PAGE_X_COORD
	inc SPRITE_ZERO_PAGE_FRAME
	jsr smux_drawSprite
	rts

stoneface_dead:
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
	:add16 #18;OBJECT_ZERO_PAGE_X_COORD
	jsr objectroutines_createObject

	pla
	tax

	lda #OBJECT_NONE
	sta _objectarray_type, x
	rts

