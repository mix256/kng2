
_smux_sprite_buffer_x:	// 2 buffers, X sprites each
	.fill NUMBER_OF_SMUX_SPRITES, 0
	.fill NUMBER_OF_SMUX_SPRITES, 0

_smux_sprite_buffer_x_msb:	// 2 buffers, X sprites each
	.fill NUMBER_OF_SMUX_SPRITES, 0
	.fill NUMBER_OF_SMUX_SPRITES, 0
	
_smux_sprite_buffer_y:
	.fill NUMBER_OF_SMUX_SPRITES, $ff
	.fill NUMBER_OF_SMUX_SPRITES, $ff
	
_smux_sprite_buffer_color:
	.fill NUMBER_OF_SMUX_SPRITES, 0
	.fill NUMBER_OF_SMUX_SPRITES, 0
	
_smux_sprite_buffer_frame:
	.fill NUMBER_OF_SMUX_SPRITES, 0
	.fill NUMBER_OF_SMUX_SPRITES, 0

_smux_sprites_sorted_index:
	.byte 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
	.byte 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
	
_smux_sort_done:
	.byte 0

//
//
//
.pc = * "smux_sortBufferWithClear"

//##############################################
//
// Sprite Sort routine
//
//##############################################

smux_sortBufferWithClear:
	lda _irq_sprite_front_buffer
	beq smux_sbwc01
	jmp smux_sortBufferWithClearBuffer0
smux_sbwc01:
	jmp smux_sortBufferWithClearBuffer1

smux_sortBufferWithClearBuffer0:

	// Clear Index list
	ldx #0
smux_sb101:
	lda _smux_sprites_sorted_index + SPRITE_BUFFER_1, x
	sta _smux_sprites_sorted_index + SPRITE_BUFFER_0, x
	inx
	cpx #NUMBER_OF_SMUX_SPRITES
	bne smux_sb101

	// Bubble sort
smux_sb104:
	ldx #0
	:clear(_smux_sort_done)
smux_sb102:
	stx $fa
	lda _smux_sprites_sorted_index + SPRITE_BUFFER_0, x
	tay
	lda _smux_sprites_sorted_index + SPRITE_BUFFER_0 + 1, x
	tax
	lda _smux_sprite_buffer_y + SPRITE_BUFFER_0 - 1, x
	sec
	sbc _smux_sprite_buffer_y + SPRITE_BUFFER_0 - 1, y
	bcs smux_sb103

	ldx $fa
	:swap _smux_sprites_sorted_index + SPRITE_BUFFER_0, x;_smux_sprites_sorted_index + SPRITE_BUFFER_0 + 1, x
	inc _smux_sort_done
smux_sb103:
	ldx $fa
	inx
	cpx #NUMBER_OF_SMUX_SPRITES - 1
	bne smux_sb102
	lda _smux_sort_done
	bne smux_sb104
	rts

smux_sortBufferWithClearBuffer1:

	// Clear Index list
	ldx #0
smux_sb101b1:
	lda _smux_sprites_sorted_index + SPRITE_BUFFER_0, x
	sta _smux_sprites_sorted_index + SPRITE_BUFFER_1, x
	inx
	cpx #NUMBER_OF_SMUX_SPRITES
	bne smux_sb101b1

	// Bubble sort
smux_sb104b1:
	ldx #0
	:clear(_smux_sort_done)
smux_sb102b1:
	stx $fa
	lda _smux_sprites_sorted_index + SPRITE_BUFFER_1, x
	tay
	lda _smux_sprites_sorted_index + SPRITE_BUFFER_1 + 1, x
	tax
	lda _smux_sprite_buffer_y + SPRITE_BUFFER_1 - 1, x
	sec
	sbc _smux_sprite_buffer_y + SPRITE_BUFFER_1 - 1, y
	bcs smux_sb103b1

	ldx $fa
	:swap _smux_sprites_sorted_index + SPRITE_BUFFER_1, x;_smux_sprites_sorted_index + SPRITE_BUFFER_1 + 1, x
	inc _smux_sort_done
smux_sb103b1:
	ldx $fa
	inx
	cpx #NUMBER_OF_SMUX_SPRITES - 1
	bne smux_sb102b1
	lda _smux_sort_done
	bne smux_sb104b1
	rts

//#######################################################
//
// Resets the on screen sprites
//
//#######################################################

smux_resetSprites:
	lda _irq_sprite_front_buffer
	beq smux_restsp01
	jmp smux_resetSpritesBuffer0
smux_restsp01:
	jmp smux_resetSpritesBuffer1

smux_resetSpritesBuffer0:
	// Clear Index list
	ldx #0
smux_rstsp01:
	lda #$ff
	sta _smux_sprite_buffer_y + SPRITE_BUFFER_0, x
	lda #0
	sta _smux_sprite_buffer_frame + SPRITE_BUFFER_0, x
	inx
	cpx #NUMBER_OF_SMUX_SPRITES
	bne smux_rstsp01
	rts

smux_resetSpritesBuffer1:
	// Clear Index list
	ldx #0
smux_rstsp01b1:
	lda #$ff
	sta _smux_sprite_buffer_y + SPRITE_BUFFER_1, x
	lda #0
	sta _smux_sprite_buffer_frame + SPRITE_BUFFER_1, x
	inx
	cpx #NUMBER_OF_SMUX_SPRITES
	bne smux_rstsp01b1
	rts

//#######################################################
//
// Sets a sprite on screen
//
//#######################################################

smux_drawSprite:
	lda _irq_sprite_front_buffer
	beq smux_drsp01
	jmp smux_drawSpriteBuffer0
smux_drsp01:	
	jmp smux_drawSpriteBuffer1

smux_drawSpriteBuffer0:
	ldx #0
smux_drspr01:
	lda _smux_sprite_buffer_frame + SPRITE_BUFFER_0, x
	beq smux_drspr02
	inx
	cpx #NUMBER_OF_SMUX_SPRITES
	bne smux_drspr01
	rts

smux_drspr02:
	lda SPRITE_ZERO_PAGE_X_COORD
	sta _smux_sprite_buffer_x + SPRITE_BUFFER_0, x
	lda SPRITE_ZERO_PAGE_X_MSB_COORD
	sta _smux_sprite_buffer_x_msb + SPRITE_BUFFER_0, x
	lda SPRITE_ZERO_PAGE_Y_COORD
	sta _smux_sprite_buffer_y+ SPRITE_BUFFER_0, x
	lda SPRITE_ZERO_PAGE_COLOR
	sta _smux_sprite_buffer_color + SPRITE_BUFFER_0, x
	lda SPRITE_ZERO_PAGE_FRAME
	sta _smux_sprite_buffer_frame + SPRITE_BUFFER_0, x
	rts

smux_drawSpriteBuffer1:
	ldx #0
smux_drspr01b1:
	lda _smux_sprite_buffer_frame + SPRITE_BUFFER_1, x
	beq smux_drspr02b1
	inx
	cpx #NUMBER_OF_SMUX_SPRITES
	bne smux_drspr01b1
	rts

smux_drspr02b1:
	lda SPRITE_ZERO_PAGE_X_COORD
	sta _smux_sprite_buffer_x + SPRITE_BUFFER_1, x
	lda SPRITE_ZERO_PAGE_X_MSB_COORD
	sta _smux_sprite_buffer_x_msb + SPRITE_BUFFER_1, x
	lda SPRITE_ZERO_PAGE_Y_COORD
	sta _smux_sprite_buffer_y+ SPRITE_BUFFER_1, x
	lda SPRITE_ZERO_PAGE_COLOR
	sta _smux_sprite_buffer_color + SPRITE_BUFFER_1, x
	lda SPRITE_ZERO_PAGE_FRAME
	sta _smux_sprite_buffer_frame + SPRITE_BUFFER_1, x
	rts
	