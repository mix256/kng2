
_input_fast_fire_repeat:
	.byte 1
_input_joy_unrepeat:
	.byte 0,0,0,0,0
_input_joy_pressed:
	.byte 0,0,0,0,0
_input_joy_pressed_last:
	.byte 0,0,0,0,0

//------------------------------------------------
// Input Joystick Detection
//------------------------------------------------

input_readJoy:
	lda #1
	sta _input_joy_unrepeat
	sta _input_joy_unrepeat + 1
	sta _input_joy_unrepeat + 2
	sta _input_joy_unrepeat + 3
	sta _input_joy_unrepeat + 4

	lda $dc00
	tax
	and #1
	sta _input_joy_pressed
	txa
	and #2
	sta _input_joy_pressed + 1
	txa
	and #4
	sta _input_joy_pressed + 2
	txa
	and #8
	sta _input_joy_pressed + 3
	txa
	and #16
	sta _input_joy_pressed + 4

//
	lda _input_joy_pressed
	bne input_jpl01
	lda _input_joy_pressed_last
	beq input_jpl01
	lda #0
	sta _input_joy_unrepeat
input_jpl01:
	sta _input_joy_pressed_last
//
	lda _input_joy_pressed + 1
	bne input_jpl02
	lda _input_joy_pressed_last + 1
	beq input_jpl02
	lda #0
	sta _input_joy_unrepeat + 1
input_jpl02:
	sta _input_joy_pressed_last + 1

	lda _input_joy_pressed + 2
	bne input_jpl03
	lda _input_joy_pressed_last + 2
	beq input_jpl03
	lda #0
	sta _input_joy_unrepeat + 2
input_jpl03:
	sta _input_joy_pressed_last + 2

	lda _input_joy_pressed + 3
	bne input_jpl04
	lda _input_joy_pressed_last + 3
	beq input_jpl04
	lda #0
	sta _input_joy_unrepeat + 3
input_jpl04:
	sta _input_joy_pressed_last + 3

	// Fire
	lda _input_joy_pressed + 4
	bne input_jpl05
	lda _input_joy_pressed_last + 4
	beq input_jpl05b
	lda #0
	sta _input_joy_unrepeat + 4
	sta _input_fast_fire_repeat
	sta _input_joy_pressed_last + 4
	rts
input_jpl05:
	sta _input_joy_pressed_last + 4
	sta _input_fast_fire_repeat

	rts

input_jpl05b:
	inc _input_fast_fire_repeat
	lda _input_fast_fire_repeat
	cmp #3
	bne input_jpl05bc
	lda #0
	sta _input_fast_fire_repeat
input_jpl05bc:
	rts
