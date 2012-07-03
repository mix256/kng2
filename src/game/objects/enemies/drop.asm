
.const DROP_START_FRAME		=	FRAME_ENEMIES_START + 18
.const DROP_END_FRAME		=	FRAME_ENEMIES_START + 23

drop_routines:
	jmp drop_create
	jmp drop_update
	jmp drop_dead
	jmp drop_draw

drop_create:
	lda #COLLISION_WITH_MAIN + COLLISION_WITH_MAINBULLET
	sta _objectarray_collisionType, x

	lda #15
	sta _objectarray_hits, x

	lda #24
	sta _objectarray_width, x
	lda #21
	sta _objectarray_height, x

	lda #ANIMATION_TYPE_LOOP
	sta _animation_type, x
	lda #DROP_START_FRAME
	sta _animation_start_frame, x
	lda #DROP_END_FRAME
	sta _animation_end_frame, x
	lda #12
	sta _animation_speed, x
	jsr animation_setAnimation
	
	lda #0
	sta _objectarray_user_properties,x
	
	rts


drop_update:
	// Hit (TODO: Change)
	lda _objectarray_was_hit, x
	beq drop_u01
	dec _objectarray_hits, x
	lda _objectarray_hits, x
	beq drop_dead
drop_u01:

	// Check clipping
	jsr objectroutines_clipObject

	// Animate
	jsr animation_updateFrame

	// Move
	:compare16_x mainplayer_position;_objectarray_x_coord,x;_objectarray_x_msb_coord, x	
	bne drop_u03
	lda #1
	sta _objectarray_user_properties, x
drop_u03:
	
	lda _objectarray_user_properties, x
	beq drop_u02
	lda #DROP_END_FRAME - 1
	sta _animation_current_frame, x
	
	:moveObject8 #3;_objectarray_y_coord,x
	and #%11111000
	beq drop_dead
drop_u02:

	jsr objectroutines_scrollObject

	// Draw
	jsr drop_draw
	rts

drop_draw:
	jsr objectroutines_drawObject
	rts

drop_dead:
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

