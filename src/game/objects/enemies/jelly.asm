
.const JELLY_START_FRAME = FRAME_ENEMIES_START + 25
.const JELLY_END_FRAME = FRAME_ENEMIES_START + 27

jelly_routines:
	jmp jelly_create
	jmp jelly_update
	jmp jelly_dead
	jmp jelly_draw

jelly_create:
	lda #COLLISION_WITH_MAIN + COLLISION_WITH_MAINBULLET
	sta _objectarray_collisionType, x

	lda #3
	sta _objectarray_hits, x

	lda #24
	sta _objectarray_width, x
	lda #21
	sta _objectarray_height, x

	lda #ANIMATION_TYPE_LOOP
	sta _animation_type, x
	lda #JELLY_START_FRAME
	sta _animation_start_frame, x
	lda #JELLY_END_FRAME
	sta _animation_end_frame, x
	lda #6
	sta _animation_speed, x
	jsr animation_setAnimation
	rts



jelly_x_tab:
	.word 0,0,0,-1,-1,-1,-2,-2,-2,-3,-3,-3,-2,-2,-2,-1,-1,-1,0,0,0,1,1,1,2,2,2,3,3,3,2,2,2,1,1,1


jelly_update:
	// Hit (TODO: Change)
	lda _objectarray_was_hit, x
	beq jelly_u01
	dec _objectarray_hits, x
jelly_u01:
	lda _objectarray_hits, x
	beq jelly_dead

	// Check clipping
	jsr objectroutines_clipObject

	// Move
	:moveObjectWithTab4 _objectarray_user_properties + [NUMBER_OF_OBJECTS * 0], x;#36;jelly_x_tab,y;_objectarray_x_coord, x
	:moveObject #-2;_objectarray_x_coord, x

	// Animate
	jsr animation_updateFrame

	// Draw
	jsr jelly_draw
	
	rts

jelly_draw:
	jsr objectroutines_drawObject
	rts

jelly_dead:
	txa
	pha

	lda #OBJECT_PHOENIX
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

