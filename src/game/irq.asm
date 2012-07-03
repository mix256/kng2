
_irq_new_frame_started:
	.byte 0

_irq_time_to_swith_buffer:
	.byte 0

_irq_d016_back: // upcoming x scroll
	.byte 7
_irq_d016_front: // current x scroll
	.byte 0

_irq_screen_mem_front:
	.word $c000
_irq_screen_mem_back:
	.word $c400

_irq_d018_front:
	.byte %00000010
_irq_d018_back:
	.byte %00010010

_irq_sprite_front_buffer:
	.byte 0 // buffer0(0) or buffer1(1)

_irq_switch_sprite_buffers:
	.byte 0

_irq_d010:
	.byte 0

_irq_exp:
	.byte 1,1,2,2,4,4,8,8,16,16,32,32,64,64,128,128

irq_clearAllData:
	lda #0
	sta _irq_new_frame_started
	sta _irq_time_to_swith_buffer
	lda #$c0
	sta _irq_screen_mem_front + 1
	lda #$c4
	sta _irq_screen_mem_back + 1
	lda #%00000010
	sta _irq_d018_front
	lda #%00010010
	sta _irq_d018_back
	lda #7
	sta _irq_d016_back
	lda #0
	sta _irq_d016_front
	rts

irq_rasterIrqSetup:
	sei
	:mov #1;$d01a
	:mov16 #irq_routinePlayfield; $0314
	:mov #255; $d012
	:clear(_irq_new_frame_started)
	cli
	rts

irq_switchBuffers:
	:switch16(_irq_screen_mem_front,_irq_screen_mem_back)
	:switch8(_irq_d018_front,_irq_d018_back)
	:clear(_irq_time_to_swith_buffer)
	rts

irq_frameDone:
	lda _irq_d016_back
	and #7
	sta _irq_d016_back
	:mov _irq_d016_back;_irq_d016_front
	:clear(_irq_new_frame_started)

	:set(_irq_switch_sprite_buffers)

	lda _irq_time_to_swith_buffer
	beq irq_sb01
	jmp irq_switchBuffers
irq_sb01:
	rts


irq_waitForNewFrame:
	lda _irq_new_frame_started
	beq irq_waitForNewFrame
	rts


irq_routinePlayfield:
	inc $d019
	lda $d016
	and #%11111000
	ora _irq_d016_front
	sta $d016
	:mov _irq_d018_front;$d018
	:set(_irq_new_frame_started)
	:clear(ZERO_PAGE_1_IN_IRQ)

	lda #$ff
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	sta $d009
	sta $d00b
	sta $d00d
	sta $d00f
	
	lda _irq_switch_sprite_buffers
	beq irq_ropf02	
	:clear(_irq_switch_sprite_buffers)
	lda _irq_sprite_front_buffer
	eor #1
	sta _irq_sprite_front_buffer
irq_ropf02:	
	lda _irq_sprite_front_buffer
	bne irq_ropf01

	:mov16 #irq_drawHardwareSpritesBuffer0; $0314
	:mov #50-24; $d012
	jmp $ea81
irq_ropf01:	
	:mov16 #irq_drawHardwareSpritesBuffer1; $0314
	:mov #50-24; $d012

	jmp $ea81


irq_drawHardwareSpritesBuffer0:
	inc $d019
	:rastercheck(1)

	:clear(_irq_d010)

	ldx #0
irq_dhws01:	
	stx ZERO_PAGE_0_IN_IRQ
	ldx ZERO_PAGE_1_IN_IRQ
	lda _smux_sprites_sorted_index + SPRITE_BUFFER_0, x
	tay
	dey
	lda _smux_sprite_buffer_frame + SPRITE_BUFFER_0, y
	beq irq_smux_done
	
	ldx ZERO_PAGE_0_IN_IRQ
	sta $c3f8, x
	sta $c7f8, x
	lda _smux_sprite_buffer_color + SPRITE_BUFFER_0, y
	sta $d027, x
	txa
	asl
	tax
	lda _smux_sprite_buffer_y + SPRITE_BUFFER_0, y
	sta $d001, x
	lda _smux_sprite_buffer_x + SPRITE_BUFFER_0, y
	sta $d000, x

	lda _smux_sprite_buffer_x_msb + SPRITE_BUFFER_0, y
	beq irq_dhws02
	lda _irq_d010
	ora _irq_exp, x
	sta _irq_d010
irq_dhws02:

	inc ZERO_PAGE_1_IN_IRQ
	lda ZERO_PAGE_1_IN_IRQ
	cmp #NUMBER_OF_SMUX_SPRITES
	beq irq_smux_done
	ldx ZERO_PAGE_0_IN_IRQ
	inx
	cpx #8
	bne irq_dhws01

	lda _smux_sprite_buffer_y + SPRITE_BUFFER_0, y
	clc
	adc #16
	bcs irq_smux_done
	sta $d012

	lda _irq_d010
	sta $d010

	:rastercheck(0)

	jmp $ea81
	
irq_smux_done:	
// End of sprites, begin new frame
	lda _irq_d010
	sta $d010

	:mov16 #irq_routinePlayfield; $0314
	:mov #$ff; $d012
	
	:rastercheck(0)
	
	jmp $ea81
		
irq_drawHardwareSpritesBuffer1:
	inc $d019
	:rastercheck(1)

	:clear(_irq_d010)

	ldx #0
irq_dhws01_b1:	
	stx ZERO_PAGE_0_IN_IRQ
	ldx ZERO_PAGE_1_IN_IRQ
	lda _smux_sprites_sorted_index + SPRITE_BUFFER_1, x
	tay
	dey
	lda _smux_sprite_buffer_frame + SPRITE_BUFFER_1, y
	beq irq_smux_done_b1
	
	ldx ZERO_PAGE_0_IN_IRQ
	sta $c3f8, x
	sta $c7f8, x
	lda _smux_sprite_buffer_color + SPRITE_BUFFER_1, y
	sta $d027, x
	txa
	asl
	tax
	lda _smux_sprite_buffer_y + SPRITE_BUFFER_1, y
	sta $d001, x
	lda _smux_sprite_buffer_x + SPRITE_BUFFER_1, y
	sta $d000, x

	lda _smux_sprite_buffer_x_msb + SPRITE_BUFFER_1, y
	beq irq_dhws02_b1
	lda _irq_d010
	ora _irq_exp, x
	sta _irq_d010
irq_dhws02_b1:

	inc ZERO_PAGE_1_IN_IRQ
	lda ZERO_PAGE_1_IN_IRQ
	cmp #NUMBER_OF_SMUX_SPRITES
	beq irq_smux_done_b1
	ldx ZERO_PAGE_0_IN_IRQ
	inx
	cpx #8
	bne irq_dhws01_b1

	lda _smux_sprite_buffer_y + SPRITE_BUFFER_1, y
	clc
	adc #16
	bcs irq_smux_done_b1
	sta $d012

	lda _irq_d010
	sta $d010

	:rastercheck(0)

	jmp $ea81
	
irq_smux_done_b1:	
// End of sprites, begin new frame

	lda _irq_d010
	sta $d010

	:mov16 #irq_routinePlayfield; $0314
	:mov #$ff; $d012
	
	:rastercheck(0)
	
	jmp $ea81
	
	