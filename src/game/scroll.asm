
_scroll_position:
	.byte 0, 0
_scroll_happened_this_frame:
	.byte 0
scroll_time_to_stop:
	.byte 0
	
scroll_clearAllData:
	lda #0
	sta _scroll_position
	sta _scroll_position + 1
	sta _scroll_happened_this_frame
	sta scroll_time_to_stop
	:mov #0;_scroll_frontXStart + 1
	sta _scroll_backXStart + 1
	:mov #25;_scroll_frontXEnd + 1
	sta _scroll_backXEnd + 1
	
scroll_hitEnd:
	rts

scroll_scrollLeft:
	:clear(_scroll_happened_this_frame)

	lda _tiledata_room_size	// Check if end of room
	beq scroll_hitEnd

	lda scroll_time_to_stop
	beq scroll_scrlef01
	dec scroll_time_to_stop
	lda scroll_time_to_stop
	bne scroll_scrlef01
	inc scroll_time_to_stop
	rts
scroll_scrlef01:
	
	:set(_scroll_happened_this_frame)

	lda _scroll_position	// Decrease room size
	and #31
	cmp #15
	bne scroll_scle01
	dec _tiledata_room_size
scroll_scle01:

	:add16 #1;_scroll_position
	:sub8 #1;_irq_d016_back
	bcs scroll_noBufferSwitch
	:set(_irq_time_to_swith_buffer)
scroll_noBufferSwitch:
	jsr scroll_byteScrollScreenLeft
	:add8 #25;_scroll_frontXStart + 1
	:add8 #25;_scroll_frontXEnd + 1
	:add8 #25;_scroll_backXStart + 1
	:add8 #25;_scroll_backXEnd + 1

	lda _irq_time_to_swith_buffer
	beq scroll_done

	:mov #0;_scroll_frontXStart + 1
	sta _scroll_backXStart + 1
	:mov #25;_scroll_frontXEnd + 1
	sta _scroll_backXEnd + 1

	jsr tiles_drawOnRight

scroll_done:
	rts

	// fade-temp...
	:clear(_scroll_position)
	sta _scroll_position + 1

	// test för kul!
	jsr transitions_fadeBarToWhite_init
	:clear(tiles_large_tile_in_map_pointer)
	jsr mainbullet_clearList
	//

	rts
scroll_scrollRight:	// dummy for macro


//--------------------------------------------------
//
// Scroll Left (whole byte)
//
//--------------------------------------------------

scroll_byteScrollScreenLeft:
	lda _irq_screen_mem_back + 1
	cmp #>SCREEN_BACK_BUFFER
	bne scroll_byteScrollFrontScreenLeft
	jmp scroll_byteScrollBackScreenLeft

scroll_byteScrollFrontScreenLeft:
_scroll_frontXStart:
	ldx #0
scroll_bsfsl01:
	lda SCREEN_BACK_BUFFER + 1 + 000, x
	sta SCREEN_FRONT_BUFFER  + 0 + 000, x
	lda SCREEN_BACK_BUFFER + 1 + 200, x
	sta SCREEN_FRONT_BUFFER  + 0 + 200, x
	lda SCREEN_BACK_BUFFER + 1 + 400, x
	sta SCREEN_FRONT_BUFFER  + 0 + 400, x
	lda SCREEN_BACK_BUFFER + 1 + 600, x
	sta SCREEN_FRONT_BUFFER  + 0 + 600, x
	lda SCREEN_BACK_BUFFER + 1 + 800, x
	sta SCREEN_FRONT_BUFFER  + 0 + 800, x
	inx
_scroll_frontXEnd:
	cpx #25
	bne scroll_bsfsl01
	rts

scroll_byteScrollBackScreenLeft:
_scroll_backXStart:
	ldx #0
scroll_bsbsl01:
	lda SCREEN_FRONT_BUFFER + 1 + 000, x
	sta SCREEN_BACK_BUFFER  + 0 + 000, x
	lda SCREEN_FRONT_BUFFER + 1 + 200, x
	sta SCREEN_BACK_BUFFER  + 0 + 200, x
	lda SCREEN_FRONT_BUFFER + 1 + 400, x
	sta SCREEN_BACK_BUFFER  + 0 + 400, x
	lda SCREEN_FRONT_BUFFER + 1 + 600, x
	sta SCREEN_BACK_BUFFER  + 0 + 600, x
	lda SCREEN_FRONT_BUFFER + 1 + 800, x
	sta SCREEN_BACK_BUFFER  + 0 + 800, x
	inx
_scroll_backXEnd:
	cpx #25
	bne scroll_bsbsl01
	rts

scroll_scrollInit:
	ldx #160
scroll_scrini01:	
	txa
	pha
	jsr scroll_scini02
	jsr scroll_scini02
	pla
	tax
	dex
	bne scroll_scrini01

	// delay scroll/adder for 3 seconds	
	lda #180
	sta _kng2_new_stage_intro_counter
	
	rts
scroll_scini02:
	jsr scroll_scrollLeft
	jsr irq_frameDone
	rts
	
