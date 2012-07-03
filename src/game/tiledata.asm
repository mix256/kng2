
_tiledata_data_start:
	.word 0
_tiledata_room_size:
	.byte 0

//
// IN:	X = Room number
// OUT:	_tiledata_data_start(w) =
//		_tiledata_room_size(b) = size of room in large tiles (32px)

tiledata_setup:
// Number of rooms
// TODO: never used?!
//	lda tiledata_start + NUMBER_OF_ROOMS_POINTER

	stx _tmp_1
	lda #<[tiledata_start + 1]
	sta $fa
	lda #>[tiledata_start + 1]
	sta $fb

	ldy #0
	ldx _tmp_1
tiledata_seu01:
	beq tiledata_setupInitRegisters
	:add16 #36;$fa
	lda ($fa),y
	clc
	adc $fa
	sta $fa
	lda $fb
	adc #0
	sta $fb
	:add16 #1;$fa
	dex
	jmp tiledata_seu01

tiledata_setupInitRegisters:
// Pallete for room
	ldx #0
	ldy #0
tiledata_s01:
	lda ($fa), y // TODO: not used...selected color!
	iny
	lda ($fa), y
	sta _nmi_split_multicolor_tab_m1 + 4, x
	sta _transitions_fadein_colors + 9, x
	iny
	lda ($fa), y
	sta _nmi_split_multicolor_tab_m2 + 4, x
	sta _transitions_fadein_colors + 18, x
	iny
	lda ($fa), Y
	sta _nmi_split_bkgcolor_tab + 4, x
	sta _transitions_fadein_colors, x
	iny
	inx
	cpy #36
	bne tiledata_s01

// Number of large-tiles in room
	lda ($fa), y
	clc
	adc #1	// add 1 to make the last tile visible
	sta _tiledata_room_size

// Room tile data start
	tya
	clc
	adc $fa
	sta _tiledata_data_start
	lda $fb
	adc #0
	sta _tiledata_data_start + 1

// Setup the first tile	
	jsr tile_getLargeTileNumber
	
	rts



tiledata_start:
.import binary "resources/graphics/generated/w0bkg"

tiledata_largetiles_start:
.import binary "resources/graphics/generated/w0ltil"

tiledata_smalltiles_start:
.import binary "resources/graphics/generated/w0stil"

