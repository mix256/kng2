
transporter_routines:
	jmp transporter_create
	jmp transporter_update
	jmp transporter_dead
	jmp transporter_draw

transporter_create:
	lda #COLLISION_WITH_MAIN
	sta _objectarray_collisionType, x

	lda #5
	sta _objectarray_hits, x

	lda #24
	sta _objectarray_width, x
	lda #21
	sta _objectarray_height, x

	lda #FRAME_MAIN_START + 18
	sta _animation_current_frame, x
	rts

transporter_colors:
	.byte 0,0,0,0,0,0,0,8
	.byte 0,0,2,0,0,5,6,0

transporter_update:
	// Hit (TODO: Change)
	lda _objectarray_was_hit, x
	beq transporter_u01
//	dec _objectarray_hits, x
//	:moveObject #2;_objectarray_x_coord, x

	// TODO: Set some number on where to go.	
	lda _objectarray_user_properties + [NUMBER_OF_OBJECTS * 0], x
	sta _game_next_level
	:set(_game_stage_clear)
	
transporter_u01:
	lda _objectarray_hits, x
	beq transporter_dead

	// Move
	jsr objectroutines_scrollObject

	// Animate
//	jsr animation_updateFrame

	// Draw
	jsr transporter_draw
	rts

transporter_draw:
	jsr objectroutines_drawObject
	inc SPRITE_ZERO_PAGE_FRAME
	lda SPRITE_ZERO_PAGE_COLOR
	tay
	lda transporter_colors, y
	sta SPRITE_ZERO_PAGE_COLOR
	jsr smux_drawSprite
	rts

transporter_dead:
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

