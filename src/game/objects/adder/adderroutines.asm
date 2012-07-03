
_adderroutines_room_pos:
	.byte 0
_adderroutines_pixel_counter:
	.byte 16

adderroutines_clearAllData:
	lda #0
	sta _adderroutines_room_pos
	lda #16
	sta _adderroutines_pixel_counter
	rts

adderroutines_process:

	lda _scroll_happened_this_frame
	beq adderroutines_p01

	inc _adderroutines_pixel_counter

	lda _adderroutines_pixel_counter
	and #31
	bne adderroutines_p01

	inc _adderroutines_room_pos

	ldx _adderroutines_room_pos
	lda _adderarray_object_type, x
	beq adderroutines_p01
	// TODO: Set object_array immediately instead of zero_page buffering.
	sta OBJECT_ZERO_PAGE_TYPE
	lda _adderarray_object_x_coord, x
	sta OBJECT_ZERO_PAGE_X_COORD
	lda _adderarray_object_x_msb_coord, x
	sta OBJECT_ZERO_PAGE_X_MSB_COORD
	lda _adderarray_object_y_coord, x
	sta OBJECT_ZERO_PAGE_Y_COORD
	lda _adderarray_object_color, x
	sta OBJECT_ZERO_PAGE_COLOR
	lda _adderarray_object_property_1, x
	sta OBJECT_ZERO_PAGE_PROPERTY_1
	lda _adderarray_object_property_2, x
	sta OBJECT_ZERO_PAGE_PROPERTY_2
	jmp objectroutines_createObject
adderroutines_p01:
	rts
	

//###############################################	
//
// iX = room number	
//
//###############################################	

adderroutines_initiateRoom:
	lda #<kng2_worldadders
	sta OBJECT_ZERO_PAGE_X_COORD
	lda #>kng2_worldadders
	sta OBJECT_ZERO_PAGE_X_MSB_COORD

	lda OBJECT_ZERO_PAGE_X_COORD
	clc
	adc tables_room_start_lo, x
	sta OBJECT_ZERO_PAGE_X_COORD
	lda OBJECT_ZERO_PAGE_X_MSB_COORD
	adc tables_room_start_hi, x
	sta OBJECT_ZERO_PAGE_X_MSB_COORD
	
	ldy #0
adderroutines_ir01:	
	lda (OBJECT_ZERO_PAGE_X_COORD), y
	sta _adderarray_object_type, y
	iny
	bne adderroutines_ir01
	
	lda OBJECT_ZERO_PAGE_X_MSB_COORD
	clc
	adc #1
	sta OBJECT_ZERO_PAGE_X_MSB_COORD
adderroutines_ir02:	
	lda (OBJECT_ZERO_PAGE_X_COORD), y
	sta _adderarray_object_type + 256, y
	iny
	bne adderroutines_ir02

	lda OBJECT_ZERO_PAGE_X_MSB_COORD
	clc
	adc #1
	sta OBJECT_ZERO_PAGE_X_MSB_COORD
adderroutines_ir03:	
	lda (OBJECT_ZERO_PAGE_X_COORD), y
	sta _adderarray_object_type + 512, y
	iny
	cpy #48
	bne adderroutines_ir03
	rts	
	
