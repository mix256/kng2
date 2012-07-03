
// 0 = none, 1 = once_stand, 2 = once_die, 3 = loop, 4 = pingpong
_animation_type:		
	.fill NUMBER_OF_ANIMATIONS, ANIMATION_TYPE_NONE
_animation_start_frame:
	.fill NUMBER_OF_ANIMATIONS, 0
_animation_end_frame:
	.fill NUMBER_OF_ANIMATIONS, 0
_animation_speed:
	.fill NUMBER_OF_ANIMATIONS, 0

// internal, no-user, properties
_animation_current_frame:
	.fill NUMBER_OF_ANIMATIONS, 0
_animation_counter:
	.fill NUMBER_OF_ANIMATIONS, 0

//#####################################################
//
// IN: 	X = animationPointer (same as object number)
//		
//#####################################################
animation_setAnimation:
	lda _animation_start_frame, x
	sta _animation_current_frame, x
	lda _animation_speed, x
	sta _animation_counter, x
animation_sa01:
	rts


animation_updateFrame:
	lda _animation_counter, x
	sec
	sbc #1
	sta _animation_counter, x
	bne animation_uf01
	lda _animation_speed, x
	sta _animation_counter, x

	lda _animation_type, x
	cmp #ANIMATION_TYPE_LOOP
	bne animation_uf02
	lda _animation_current_frame, x
	clc
	adc #1
	sta _animation_current_frame, x
	cmp _animation_end_frame, x
	bne animation_uf01
	lda _animation_start_frame, x
	sta _animation_current_frame, x
animation_uf01:	
	rts

animation_uf02:
	cmp #ANIMATION_TYPE_ONCE_DIE
	bne animation_uf03
	lda _animation_current_frame, x
	clc
	adc #1
	sta _animation_current_frame, x
	cmp _animation_end_frame, x
	bne animation_uf02b
	lda #0
	sta _objectarray_type, x
animation_uf02b:	
	rts

animation_uf03:
	cmp #ANIMATION_TYPE_ONCE_STAND
	bne animation_uf04
	lda _animation_current_frame, x
	clc
	adc #1
	cmp _animation_end_frame, x
	beq animation_uf04
	sta _animation_current_frame, x
animation_uf04:	
	rts

	

