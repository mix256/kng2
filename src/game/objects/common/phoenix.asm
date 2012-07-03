
.const PHOENIX_START_FRAME		=	84
.const PHOENIX_END_FRAME		=	87

phoenix_routines:
	jmp phoenix_create
	jmp phoenix_update
	jmp phoenix_dead
	jmp phoenix_draw

phoenix_create:
	lda #0
	sta _objectarray_collisionType, x

	lda #24
	sta _objectarray_width, x
	lda #21
	sta _objectarray_height, x

	lda _objectarray_y_coord,x
	sta _objectarray_user_properties,x

	lda #ANIMATION_TYPE_ONCE_DIE
	sta _animation_type, x
	lda #PHOENIX_START_FRAME
	sta _animation_start_frame, x
	lda #PHOENIX_END_FRAME
	sta _animation_end_frame, x
	lda #6
	sta _animation_speed, x
	jsr animation_setAnimation
	rts

phoenix_update:

	// Move
	:moveObject8 #-2;_objectarray_y_coord,x
	:moveObject8 #2;_objectarray_user_properties,x

	// Animate
	jsr animation_updateFrame

	// Draw
	jsr phoenix_draw
	rts

phoenix_draw:
	stx _tmp_1
	jsr objectroutines_drawObject
	ldx _tmp_1
	lda _objectarray_user_properties,x
	sta SPRITE_ZERO_PAGE_Y_COORD
	lda SPRITE_ZERO_PAGE_FRAME
	clc
	adc #4
	sta SPRITE_ZERO_PAGE_FRAME
	jsr smux_drawSprite	
	rts

phoenix_dead:
	lda #OBJECT_NONE
	sta _objectarray_type, x
	rts

