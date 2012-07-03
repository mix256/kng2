
//##############################################
//
//	IN: OBJECT_ZERO_PAGE_X_COORD...OBJECT_ZERO_PAGE_PROPERTY_2
//
//##############################################
objectroutines_createObject:
	ldx #0
objectroutines_ao02:
	lda _objectarray_type, x
	bne objectroutines_ao01

	lda OBJECT_ZERO_PAGE_TYPE
	sta _objectarray_type, x
	tay
	lda kng2_worldobjects, y
	sta _objectroutines_createadress + 1
	iny
	lda kng2_worldobjects, y
	sta _objectroutines_createadress + 2
	:add16 #OBJECT_ROUTINE_CREATE;_objectroutines_createadress + 1

	lda OBJECT_ZERO_PAGE_X_COORD
	sta _objectarray_x_coord, x
	lda OBJECT_ZERO_PAGE_X_MSB_COORD
	sta _objectarray_x_msb_coord, x
	lda OBJECT_ZERO_PAGE_Y_COORD
	sta _objectarray_y_coord, x
	lda OBJECT_ZERO_PAGE_COLOR
	sta _objectarray_color, x
	lda OBJECT_ZERO_PAGE_PROPERTY_1
	sta _objectarray_user_properties + [NUMBER_OF_OBJECTS * 0], x
	lda OBJECT_ZERO_PAGE_PROPERTY_2
	sta _objectarray_user_properties + [NUMBER_OF_OBJECTS * 1], x
	lda #0
	sta _objectarray_was_hit, x
_objectroutines_createadress:
	jmp $1234

objectroutines_ao01:
	inx
	cpx #NUMBER_OF_OBJECTS
	bne objectroutines_ao02
	ldx #-1
	rts

//##############################################
//
//	Update all Objects
//
//##############################################
objectroutines_updateObjects:
	ldx #0
objectroutines_uo02:
	lda _objectarray_type, x
	beq objectroutines_uo01
	stx _tmp_1
	tay
	lda kng2_worldobjects, y
	sta _objectroutines_updateadress + 1
	iny
	lda kng2_worldobjects, y
	sta _objectroutines_updateadress + 2
	:add16 #OBJECT_ROUTINE_UPDATE;_objectroutines_updateadress + 1
_objectroutines_updateadress:
	jsr $1234
	ldx _tmp_1
objectroutines_uo01:
	inx
	cpx #NUMBER_OF_OBJECTS
	bne objectroutines_uo02
	rts

//##############################################
//
//	Draw current Object
//
// IN: X = object array index
//
//##############################################

objectroutines_drawObject:
	lda _objectarray_x_coord, x
	sta SPRITE_ZERO_PAGE_X_COORD
	lda _objectarray_x_msb_coord, x
	sta SPRITE_ZERO_PAGE_X_MSB_COORD
	lda _objectarray_y_coord, x
	sta SPRITE_ZERO_PAGE_Y_COORD
	lda _animation_current_frame, x
	sta SPRITE_ZERO_PAGE_FRAME
	lda _objectarray_was_hit, x
	beq objectroutines_do01
	lda #0
	sta _objectarray_was_hit, x
	lda #1
	sta SPRITE_ZERO_PAGE_COLOR
	jmp smux_drawSprite
objectroutines_do01:
	lda _objectarray_color, x
	sta SPRITE_ZERO_PAGE_COLOR
	jmp smux_drawSprite

//##############################################
//
//	Check if object is outside view
//
// IN: X = object array index
//
//##############################################

objectroutines_clipObject:

	lda _objectarray_x_coord, x
	sec
	sbc #<[348 + 32]
	lda _objectarray_x_msb_coord, x
	sbc #>[348 + 32]
	and #%10000000
	beq objectroutines_co01

	lda _objectarray_x_coord, x
	clc
	adc _objectarray_width, x
	sta OBJECT_ZERO_PAGE_X_COORD
	lda _objectarray_x_msb_coord, x
	adc #0
	sta OBJECT_ZERO_PAGE_X_MSB_COORD

	lda OBJECT_ZERO_PAGE_X_COORD
	clc
	adc #32
	lda OBJECT_ZERO_PAGE_X_MSB_COORD
	adc #0
	cmp #-1
	beq objectroutines_co01
	
	lda _objectarray_y_coord, x
	sec
	sbc #29
	bcc objectroutines_co01	
	rts

objectroutines_co01:
	// outside X:
	lda #0
	sta _objectarray_type, x
	rts

//##############################################
//
//	Moves object if the screen scrolled
//
// IN: X = object array index
//
//##############################################

objectroutines_scrollObject:
	lda _scroll_happened_this_frame
	beq adderroutines_so01
	:moveObject #-1;_objectarray_x_coord, x
adderroutines_so01:
	rts


