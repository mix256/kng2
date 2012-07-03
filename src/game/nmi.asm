
_nmi_timer_bar_counter:
	.byte 0

nmi_initTimerIRQ:

nmi_iti01:
	lda #$e9
	cmp $d012
	bne nmi_iti01


	lda #<nmi_timerIRQ
	sta $0318
	lda #>nmi_timerIRQ
	sta $0319

	lda $dd0e
	and #$fe
	sta $dd0e

	lda #$e7           //
	sta $dd04
	lda #$05           //
	sta $dd05          // set CIA 1 timer A

	lda #%10000001
	sta $dd0d

	lda #%10010001
	sta $dd0e

	rts


nmi_timerIRQ:
	pha
	txa
	pha
	tya
	pha

	ldy _nmi_timer_bar_counter
	lda _nmi_split_bkgcolor_tab,y
	sta $d021
	lda _nmi_split_multicolor_tab_m1,y
	sta $d022
	lda _nmi_split_multicolor_tab_m2,y
	sta $d023
	iny

	cpy #13
	bne timirq01

	// AudioDriver
	jsr audio_runOnce
	ldy #0
timirq01:
	sty _nmi_timer_bar_counter

	lda $dd0d

	pla
	tay
	pla
	tax
	pla
	rti

_nmi_split_bkgcolor_tab:
	.fill 13,0
//	.byte 0,0,0,0, 8, 9, 8, 7, 1, 7, 8, 9,0
_nmi_split_multicolor_tab_m1:
	.fill 13,0
//	.byte 0,0,0,0, 7, 1, 7, 8, 9, 8, 7, 1,0
_nmi_split_multicolor_tab_m2:
	.fill 13,0
//	.byte 0,0,0,0,12,11,12,15, 1,15,12,11,0

nmi_clearAllTabs:
	lda #0
	tax
nmi_cat01:	
	sta _nmi_split_bkgcolor_tab, x
	sta _nmi_split_multicolor_tab_m1, x
	sta _nmi_split_multicolor_tab_m2, x
	inx
	cpx #13
	bne nmi_cat01
	rts

