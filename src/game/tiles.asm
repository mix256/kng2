
tiles_large_tile_in_map_pointer:
	.byte 0

tiles_large_tile_pointer:
	.byte 0,0

tiles_current_tile_x:
	.word 0

tiles_current_tile_row:
	.byte 0

tiles_clearAllData:
	lda #0
	sta tiles_large_tile_in_map_pointer
	sta tiles_large_tile_pointer
	sta tiles_large_tile_pointer + 1
	sta tiles_current_tile_x
	sta tiles_current_tile_x + 1
	sta tiles_current_tile_row
	rts	

tiles_drawOnRight:
	lda #0
	sta tiles_current_tile_row

	lda _irq_screen_mem_back
	clc
	adc #39
	sta tiles_screen_pos + 1
	lda _irq_screen_mem_back + 1
	sta tiles_screen_pos + 2

tiles_drawOnRightLoop:
	jsr tiles_drawPart

	:add16 #200;tiles_screen_pos + 1

	inc tiles_current_tile_row
	lda tiles_current_tile_row
	cmp #5
	bne tiles_drawOnRightLoop

	:add16 #5;tiles_current_tile_x
	lda tiles_current_tile_x
	cmp #20
	bne tiles_notNewTilerow

	:mov #0;tiles_current_tile_x
	sta tiles_current_tile_x + 1

	jsr tile_getLargeTileNumber

tiles_notNewTilerow:
	rts

tiles_drawPart:

	ldy tiles_current_tile_row
	jsr tiles_getSmallTileFromLargeTile

	:add16 #tiledata_smalltiles_start; tiles_tile_start + 1
	:add16 tiles_current_tile_x;tiles_tile_start + 1

	ldx #0
	ldy #0
tiles_tile_start:
	lda $1234, x
tiles_screen_pos:
	sta $1234, y
	tya
	clc
	adc #40
	tay
	inx
	cpx #5
	bne tiles_tile_start
	rts

// Y = row in large tile
tiles_getSmallTileFromLargeTile:

	lda tiles_large_tile_pointer
	clc
	adc #<tiledata_largetiles_start
	sta $fa
	lda tiles_large_tile_pointer + 1
	adc #>tiledata_largetiles_start
	sta $fb

	lda ($fa), y
	tax
	lda tables_tile_start_lo, x
	sta tiles_tile_start + 1
	lda tables_tile_start_hi, x
	sta tiles_tile_start + 2
	rts

tile_getLargeTileNumber:

	:add8 #1; tiles_large_tile_in_map_pointer
	ldy tiles_large_tile_in_map_pointer

	lda _tiledata_data_start
	sta $fa
	lda _tiledata_data_start + 1
	sta $fb

	lda ($fa), y
	tax
	lda tables_tile_large_start_lo, x
	sta tiles_large_tile_pointer
	lda tables_tile_large_start_hi, x
	sta tiles_large_tile_pointer + 1

//	:add16 #5;tiles_large_tile_pointer

	rts



tiles_clearColorMem:
	ldx #0
	lda #$08
tiles_ccm01:
	sta $d800,x
	sta $d900,x
	sta $da00,x
	sta $db00,x
	dex
	bne tiles_ccm01
	rts

_tiltest:
	.byte 0, 0


