
largepillar_routines:
	jmp largepillar_create
	jmp largepillar_update
	jmp largepillar_dead
	jmp largepillar_draw

largepillar_create:
	lda #COLLISION_WITH_MAIN + COLLISION_WITH_MAINBULLET
	sta _objectarray_collisionType, x

	lda #20
	sta _objectarray_hits, x

	lda #24
	sta _objectarray_width, x
	lda #40
	sta _objectarray_height, x

	lda #FRAME_ENEMIES_START + 23
	sta _animation_current_frame, x
	rts


largepillar_update:
	// Hit (TODO: Change)
	lda _objectarray_was_hit, x
	beq largepillar_u01
	dec _objectarray_hits, x
	lda _objectarray_hits, x
	beq largepillar_dead
largepillar_u01:

	// Check clipping
	jsr objectroutines_clipObject

	// Move
	jsr objectroutines_scrollObject

	// Draw
	jsr largepillar_draw
	rts

largepillar_draw:
	jsr objectroutines_drawObject
	:add8 #21;SPRITE_ZERO_PAGE_Y_COORD
	inc SPRITE_ZERO_PAGE_FRAME
	jsr smux_drawSprite	
	rts

largepillar_dead:
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
	
	pla
	tax

	lda #OBJECT_NONE
	sta _objectarray_type, x
	rts

