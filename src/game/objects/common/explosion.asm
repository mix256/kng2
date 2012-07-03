
.const EXPLOSION_START_FRAME	=	72
.const EXPLOSION_END_FRAME		=	78

explosion_routines:
	jmp explosion_create
	jmp explosion_update
	jmp explosion_dead
	jmp explosion_draw

explosion_create:
	lda #0
	sta _objectarray_collisionType, x

	lda #24
	sta _objectarray_width, x
	lda #21
	sta _objectarray_height, x

	lda #ANIMATION_TYPE_ONCE_DIE
	sta _animation_type, x
	lda #EXPLOSION_START_FRAME
	sta _animation_start_frame, x
	lda #EXPLOSION_END_FRAME
	sta _animation_end_frame, x
	lda #2
	sta _animation_speed, x
	jsr animation_setAnimation
	rts

explosion_update:
	// Change speed(slower) after 2 frames.
	lda _animation_current_frame, x
	cmp #EXPLOSION_START_FRAME + 2
	bne explosion_u01
	lda #5
	sta _animation_speed, x
explosion_u01:

	// Animate
	jsr animation_updateFrame

	// Move 
	:moveObject8 #-1;_objectarray_y_coord, x
	
	// Draw
	jsr explosion_draw
	rts

explosion_draw:
	jsr objectroutines_drawObject
	rts

explosion_dead:
	lda #OBJECT_NONE
	sta _objectarray_type, x
	rts

