
_mainbullet_bullet_pos:
	.fill MAX_NO_MAINBULLETS, 0	
_mainbullet_clear_buffer_back:
	.byte 0

//-----------------------------------------------------
// Clear all bullets
//-----------------------------------------------------
mainbullet_clearList:
	ldx #0
	txa
mainbullet_cl01:
	sta _mainbullet_bullet_pos, x
	inx
	inx
	cpx #MAX_NO_MAINBULLETS
	bne mainbullet_cl01
	rts

//-----------------------------------------------------
// Activate a bullet
// X/Y: Pos of bullet
//-----------------------------------------------------
mainbullet_add:
	stx _tmp_1
	ldx #0
mainbullet_a02:
	lda _mainbullet_bullet_pos, x
	bne mainbullet_a01
	tya
	sta _mainbullet_bullet_pos + 1, x
	lda _tmp_1
	sta _mainbullet_bullet_pos, x
	rts
mainbullet_a01:
	inx
	inx
	cpx #MAX_NO_MAINBULLETS
	bne mainbullet_a02
	rts

//-----------------------------------------------------
// Undraw all active bullets
//-----------------------------------------------------
mainbullet_unDraw:
	lda _mainbullet_clear_buffer_back
	bne mainbullet_clearBackbuffer

	ldx #0
mainbullet_ud01:
	lda _mainbullet_bullet_pos, x
	beq mainbullet_ud02
	lda _mainbullet_bullet_pos + 1, x
	asl
	tay

	lda tables_screen_row, y
	clc
	adc _irq_screen_mem_front
	sta $fa
	lda tables_screen_row + 1, y
	adc _irq_screen_mem_front + 1
	sta $fb

	ldy _mainbullet_bullet_pos, x
	lda ($fa), y
	beq mainbullet_remove2a
	lda #0
	sta ($fa), y
mainbullet_ud02b:
	iny
	lda ($fa), y
	beq mainbullet_remove2b
	lda #0
	sta ($fa), y
mainbullet_ud02:
	inx
	inx
	cpx #MAX_NO_MAINBULLETS
	bne mainbullet_ud01
	rts

mainbullet_remove2a:
	sta _mainbullet_bullet_pos, x
	jmp mainbullet_ud02b
mainbullet_remove2b:
	sta _mainbullet_bullet_pos, x
	jmp mainbullet_ud02



mainbullet_clearBackbuffer:
	ldx #0
mainbullet_ud01b:
	lda _mainbullet_bullet_pos, x
	beq mainbullet_ud03
	lda _mainbullet_bullet_pos + 1, x
	asl
	tay

	lda tables_screen_row, y
	clc
	adc _irq_screen_mem_back
	sta $fa
	lda tables_screen_row + 1, y
	adc _irq_screen_mem_back + 1
	sta $fb

	ldy _mainbullet_bullet_pos, x
	lda ($fa), y
	beq mainbullet_remove3a
	lda #0
	sta ($fa), y
mainbullet_ud03b:
	iny
	lda ($fa), y
	beq mainbullet_remove3b
	lda #0
	sta ($fa), y
mainbullet_ud03:
	inx
	inx
	cpx #MAX_NO_MAINBULLETS
	bne mainbullet_ud01b

	:clear(_mainbullet_clear_buffer_back)
	rts
mainbullet_remove3a:
	sta _mainbullet_bullet_pos, x
	jmp mainbullet_ud03b
mainbullet_remove3b:
	sta _mainbullet_bullet_pos, x
	jmp mainbullet_ud03

//-----------------------------------------------------
// Move all active bullets
//-----------------------------------------------------

mainbullet_move:
	ldx #0
mainbullet_m01:
	lda _mainbullet_bullet_pos, x
	beq mainbullet_m02
	inc _mainbullet_bullet_pos, x
	inc _mainbullet_bullet_pos, x
	lda _mainbullet_bullet_pos, x
	sec
	sbc #39
	bcc mainbullet_m02
	lda #0
	sta _mainbullet_bullet_pos, x
mainbullet_m02:
	inx
	inx
	cpx #MAX_NO_MAINBULLETS
	bne mainbullet_m01
	rts


//-----------------------------------------------------
// Draw all active bullets
//-----------------------------------------------------
mainbullet_draw:
	ldx #0
mainbullet_d01:
	lda _mainbullet_bullet_pos, x
	beq mainbullet_d02
	lda _mainbullet_bullet_pos + 1, x
	asl
	tay

	lda tables_screen_row, y
	clc
	adc _irq_screen_mem_front
	sta $fa
	lda tables_screen_row + 1, y
	adc _irq_screen_mem_front + 1
	sta $fb

	ldy _mainbullet_bullet_pos, x
	lda ($fa), y
	bne mainbullet_remove
	iny
	lda ($fa), y
	bne mainbullet_remove
	dey
	lda #MAIN_BULLET_CHARACTER
	sta ($fa), y
	iny
	lda #MAIN_BULLET_CHARACTER + 1
	sta ($fa), y
mainbullet_d02:
	inx
	inx
	cpx #MAX_NO_MAINBULLETS
	bne mainbullet_d01

	lda _irq_time_to_swith_buffer
	beq mainbullet_nttsb01
	:set(_mainbullet_clear_buffer_back)
mainbullet_nttsb01:
	rts
mainbullet_remove:
	lda #0
	sta _mainbullet_bullet_pos, x
	jmp mainbullet_d02

