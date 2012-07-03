
_game_stage_clear:
	.byte 0

// TEMP!!!
_game_next_level:
	.byte 0

game_gr02:
	clc
	rts	
game_gameRunner:
	lda _game_stage_clear
	beq game_gr02

	// Disable sprites
	:mov #0;$d015
	
	// White bars in
	jsr transitions_fadeBarToWhite_init
	jsr transition_transitionRunner
	
	// Print stage text and view map...
	jsr font_setupFontScreen
	lda _game_next_level
	cmp #0
	bne game_gr03
		:drawCenteredText(game_testtext_stage0, $c000 + 20 + 200, game_testtext_stage0_0 - game_testtext_stage0)
		:drawCenteredText(game_testtext_stage0_0, $c000 + 20 + 320, game_testtext_stage0_1 - game_testtext_stage0_0)
		jmp game_gree
game_gr03:
	cmp #1
	bne game_gr04
		:drawCenteredText(game_testtext_stage0, $c000 + 20 + 200, game_testtext_stage0_0 - game_testtext_stage0)
		:drawCenteredText(game_testtext_stage0_1, $c000 + 20 + 320, game_testtext_stage0_2 - game_testtext_stage0_1)
		jmp game_gree
game_gr04:
	cmp #2
	bne game_gr05
		:drawCenteredText(game_testtext_stage0, $c000 + 20 + 200, game_testtext_stage0_0 - game_testtext_stage0)
		:drawCenteredText(game_testtext_stage0_2, $c000 + 20 + 320, game_testtext_stage0_2e - game_testtext_stage0_2)
		jmp game_gree
game_gr05:
game_gree:
	:wait(4)

	// Fade to black
	lda #10
	sta _transitions_fade_speed
	jsr transitions_fadeOutToBlack_init
	jsr transition_transitionRunnerLock
	:waitVBlank()

	// Fade from black
	jsr transitions_fadeInFromBlack_init

	// Clear enemies/bullets etc
	jsr mainbullet_clearList
	
	:hideScreen()
	
	// Init stage
	jsr tiles_clearAllData
	jsr scroll_clearAllData
	jsr irq_clearAllData
	
//	inc _game_next_level
//	lda _game_next_level
//	and #1
//	tax
	ldx _game_next_level
	jsr tiledata_setup
	jsr nmi_clearAllTabs
	jsr scroll_scrollInit
	ldx _game_next_level
	jsr adderroutines_initiateRoom

	:clear(_game_stage_clear)
	// Enable sprites
	:mov #$ff;$d015
	lda #11
	sta $d025
	lda #1
	sta $d026

	// Clear all objects and adder
	jsr objectarray_clear
	jsr adderroutines_clearAllData
	jsr smux_resetSpritesBuffer0
	jsr smux_resetSpritesBuffer1
	
	jsr mainplayer_prepareNewStage
	
	:viewScreen()
	sec
	rts

game_testtext_stage0:
	.text "golden cage@"
game_testtext_stage0_0:
	.text "escape@"

game_testtext_stage0_1:
	.text "castle path@"

game_testtext_stage0_2:
	.text "castle bridge@"
game_testtext_stage0_2e:
	