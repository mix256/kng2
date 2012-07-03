
.import source "src/game/constants.asm"
.import source "src/macros/macros.asm"

//###################################################
//
// SOURCE
//
//###################################################

.pc =$0801 "Upstart Program"
:BasicUpstart($0810)

.pc =$0810 "Init"

	:waitVBlank()

	lda $d011
	and #%01111111
	sta _d011tmp

	:hideScreen()

	sei
	:mov #0; $d020

	// Disable timer IRQs
	lda #$7f
	sta $dc0d
	sta $dd0d
	lda $dc0d
	lda $dd0d

	// Activate Multicolor Mode and 38 chars/line
	lda $d016
	and #%11100111
	ora #%00010000
	sta $d016

	// Change char and screen pointers
	lda #%00000010
	sta $d018

	lda $dd00
	and #%11111100
	ora #GFX_DD00
	sta $dd00

	// Disable Basic
	lda #$36
	sta $01

	:mov #$0; $d020
	sta $d021
	sta $d022
	sta $d023
	sta $d025
	sta $d026

	:mov #$ff; $d015
	sta $d01c

	jsr nmi_initTimerIRQ

	jsr tiles_clearColorMem

	//jsr irq_clearBackBuffer
	//jsr irq_clearFrontBuffer

	jsr irq_rasterIrqSetup

	jsr mainbullet_clearList

	//lda #20
	//sta _transitions_fade_speed
	//jsr transitions_fadeOutToBlack_init
	jsr transitions_fadeInFromBlack_init

	ldx #0				// room number
	jsr tiledata_setup
	jsr nmi_clearAllTabs
	jsr scroll_scrollInit
	ldx #0				// room number
	jsr adderroutines_initiateRoom
	
	

/*
	//test create object
	lda #2 // OBJECT_STONEFACE
	sta OBJECT_ZERO_PAGE_TYPE
	lda #170
	sta OBJECT_ZERO_PAGE_X_COORD
	lda #0
	sta OBJECT_ZERO_PAGE_X_MSB_COORD
	lda #150
	sta OBJECT_ZERO_PAGE_Y_COORD
	lda #10
	sta OBJECT_ZERO_PAGE_COLOR
	jsr objectroutines_createObject

	lda #2 // OBJECT_STONEFACE
	sta OBJECT_ZERO_PAGE_TYPE
	lda #130
	sta OBJECT_ZERO_PAGE_X_COORD
	lda #0
	sta OBJECT_ZERO_PAGE_X_MSB_COORD
	lda #180
	sta OBJECT_ZERO_PAGE_Y_COORD
	lda #14
	sta OBJECT_ZERO_PAGE_COLOR
	jsr objectroutines_createObject

	lda #6 // OBJECT_STONEFACE
	sta OBJECT_ZERO_PAGE_TYPE
	lda #155
	sta OBJECT_ZERO_PAGE_X_COORD
	lda #0
	sta OBJECT_ZERO_PAGE_X_MSB_COORD
	lda #120
	sta OBJECT_ZERO_PAGE_Y_COORD
	lda #5
	sta OBJECT_ZERO_PAGE_COLOR
	jsr objectroutines_createObject

	lda #6 // OBJECT_STONEFACE
	sta OBJECT_ZERO_PAGE_TYPE
	lda #145
	sta OBJECT_ZERO_PAGE_X_COORD
	lda #0
	sta OBJECT_ZERO_PAGE_X_MSB_COORD
	lda #80
	sta OBJECT_ZERO_PAGE_Y_COORD
	lda #15
	sta OBJECT_ZERO_PAGE_COLOR
	jsr objectroutines_createObject
*/

	:viewScreen()

	cli

kng2_loop:
	jsr irq_waitForNewFrame

	:rastercheck(2)
	
	jsr smux_resetSprites

//
	inc _tst
	lda _tst
	bne _notd
	//jsr transitions_fadeBarToWhite_init
_notd:
//
	jsr game_gameRunner
	bcs kng2_loop
		
	jsr transition_transitionRunner

	jsr mainbullet_unDraw

	// 
	dec _kng2_new_stage_intro_counter
	lda _kng2_new_stage_intro_counter
	bne kng2_mainloop01
	
	inc _kng2_new_stage_intro_counter
	// -> scroller
	jsr scroll_scrollLeft
	// -> ObjectAdder
	jsr adderroutines_process

kng2_mainloop01:

	jsr mainbullet_move

	jsr input_readJoy

	// -> Mainplayer movement
	jsr mainplayer_checkFireButton
	jsr mainplayer_checkMovement

	jsr mainbullet_draw


	// -> Enemy/mainbullet collision check (read character, clear char if hit)
	// -> Enemy/main collision check

	:rastercheck(3)
	jsr collisiondetection_objectsVersusMain
	jsr collisiondetection_objectsVersusMainbullets
	:rastercheck(2)

	// -> Enemy move/draw
	jsr objectroutines_updateObjects

	:rastercheck(3)
	jsr smux_sortBufferWithClear
	:rastercheck(2)

	jsr irq_frameDone

	:rastercheck(0)
	jmp kng2_loop


_tst:
	.byte 0
_kng2_new_stage_intro_counter:
	.byte 0
_d011tmp:
	.byte 0

.pc = * "objectroutines"
.import source "src/game/objects/objectroutines.asm"

.pc = * "adderroutines"
.import source "src/game/objects/adder/adderroutines.asm"

.pc = * "transitions"
.import source "src/game/transitions.asm"

.pc = * "mainplayer"
.import source "src/game/mainplayer.asm"

.pc = * "mainbullet"
.import source "src/game/mainbullet.asm"

.pc = * "input"
.import source "src/game/input.asm"

.pc = * "irq"
.import source "src/game/irq.asm"

.pc = * "Sprite Multiplexor"
.import source "src/game/smux.asm"

.pc = * "nmi"
.import source "src/game/nmi.asm"

.pc = * "scroll"
.import source "src/game/scroll.asm"

.pc = * "tiles"
.import source "src/game/tiles.asm"

.pc = * "utilites"
.import source "src/game/utilites.asm"

.pc = * "font"
.import source "src/game/font.asm"

.pc = * "game"
.import source "src/game/game.asm"

//###################################################
//
// DATA
//
//###################################################

.pc = * "tables"
.import source "src/game/tables.asm"

.pc = * "tiledata"
.import source "src/game/tiledata.asm"

.pc = * "tmp"
.import source "src/game/tmp.asm"

.pc = * "objectarray"
.import source "src/game/objects/objectarray.asm"

.pc = * "animation"
.import source "src/game/objects/animation.asm"

.pc = * "collisiondetection"
.import source "src/game/objects/collisiondetection.asm"

kng2_objectadder:
.pc = * "adderarray"
.import source "src/game/objects/adder/adderarray.asm"


.pc = * "world_adders"
kng2_worldadders:
.import source "src/generated/w0/adder.asm"

.pc = * "world_objects"
kng2_worldobjects:
.import source "src/game/objects/worldobjects.asm"


//###################################################
//
// AUDIO
//
//###################################################

.pc =* "Audio"
.import source "src/game/audio.asm"

.pc =$b000 "Music Player"
.import binary "resources/audio/krasse2.bin"

//###################################################
//
// GFX
//
//###################################################

.pc = $c800 "characters"
.import binary "resources/graphics/generated/w0chars"
.pc = $d000 "sprites - main"
.import binary "resources/graphics/generated/sprites/main.bin"
.pc = * "sprites - enemies"
.import binary "resources/graphics/generated/sprites/w0.bin"

