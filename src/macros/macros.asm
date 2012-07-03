
//##############################################
//
// Functions
//
//##############################################

	.const NUM_OBJECT_SHIFTS = 4

.function _16bit_nextArgument(arg)
{
	.if (arg.getType()==AT_IMMEDIATE)
		.return CmdArgument(arg.getType(),>arg.getValue())

	.return CmdArgument(arg.getType(),arg.getValue()+1)
}

.function _16bit_nextArgument_objectStride(arg)
{
	.if (arg.getType()==AT_IMMEDIATE)
		.return CmdArgument(arg.getType(),>arg.getValue())

	.return CmdArgument(arg.getType(),arg.getValue()+NUMBER_OF_OBJECTS)
}

//##############################################
//
// Macros
//
//##############################################

.macro wait(seconds)
{
	ldx #seconds
macro_wait_s01:	
	ldy #50
macro_wait_s02:	
	:waitVBlank()
	dey
	bne macro_wait_s02
	dex
	bne macro_wait_s01
}

.macro drawText(text, pos)
{
	lda #<text
	sta $fa
	lda #>text
	sta $fb
	lda #<pos
	sta $fc
	lda #>pos
	sta $fd
	jsr font_drawText
}

.macro drawCenteredText(text, pos, width)
{
	lda #<text
	sta $fa
	lda #>text
	sta $fb
	lda #<[pos - [width]]
	sta $fc
	lda #>[pos - [width]]
	sta $fd
	jsr font_drawText
}

.macro hideScreen()
{
	:waitVBlank()
	lda $d011
	and #%11101111
	sta $d011
}

.macro viewScreen()
{
	:waitVBlank()
	lda _d011tmp
	sta $d011
}

.macro waitVBlank()
{
	lda #$ff
_m_wvbl01:	
	cmp $d012
	bne _m_wvbl01	
}

.macro rastercheck(color)
{
//	lda #color
//	sta $d020
}

.macro jmpIndirect(target)
{
	lda target
	sta _jmp + 1
	lda target + 1
	sta _jmp + 2
_jmp:
	jmp $1234
}

.macro jsrIndirect(target)
{
	lda target
	sta _jsr + 1
	lda target + 1
	sta _jsr + 2
_jsr:
	jsr $1234
}

.macro switch16(source,target)
{
	ldx source
	ldy source + 1
	lda target
	sta source
	lda target + 1
	sta source + 1
	stx target
	sty target + 1
}

.macro switch8(source,target)
{
	ldx source
	ldy target
	stx target
	sty source
}

.macro clear(target)
{
	lda #0
	sta target
}

.macro set(target)
{
	lda #1
	sta target
}

// ----------------------------------------------
// Game Handling Specific Macros
// ----------------------------------------------

.macro scrollScreenLeft(speed)
{
	lda #speed
	sta scroll_scroll_speed
	jsr scroll_scrollLeft
}

.macro scrollScreenRight(speed)
{
	lda #speed
	sta scroll_scroll_speed
	jsr scroll_scrollRight
}

//##############################################
//
// Commands
//
//##############################################

// Moves X-coord with TAB and ...
.pseudocommand moveObjectWithTab4 counter;max;tab;target
{
	lda counter
	clc
	adc #1
	sta counter
	cmp max
	bne mowt4
	lda #0
	sta counter
mowt4:	
	asl
	tay
	lda tab
	clc
	adc target
	sta target
	iny
	lda tab
	adc _16bit_nextArgument_objectStride(target)
	sta _16bit_nextArgument_objectStride(target)
}
	
.pseudocommand setUnShiftedObjectPosition source;target
{
	lda source
	clc
	rol
	sta target
	lda _16bit_nextArgument_objectStride(source)
	rol
	sta _16bit_nextArgument_objectStride(target)

	.for(var i=0;i<NUM_OBJECT_SHIFTS;i++)
	{	
		clc
		rol target
		rol _16bit_nextArgument_objectStride(target)		
	}
}

.pseudocommand setUnShiftedObjectPosition8 source;target
{
	lda source
	clc
	rol
	sta target
	lda #0
	rol
	sta _16bit_nextArgument_objectStride(target)

	.for(var i=0;i<NUM_OBJECT_SHIFTS;i++)
	{
		clc
		rol target
		rol _16bit_nextArgument_objectStride(target)	
	}
}
	
.pseudocommand setShiftedObjectPosition source;target
{
	lda _16bit_nextArgument_objectStride(source)
	clc
	ror
	sta _16bit_nextArgument_objectStride(target)
	lda source
	ror
	sta target

	.for(var i=0;i<NUM_OBJECT_SHIFTS;i++)
	{
		clc
		ror _16bit_nextArgument_objectStride(target)
		ror target	
	}
	
}

.pseudocommand setShiftedObjectPosition8 source;target;tmp
{
	lda _16bit_nextArgument_objectStride(source)
	clc
	ror
	sta tmp
	lda source
	ror
	sta target

	.for(var i=0;i<NUM_OBJECT_SHIFTS;i++)
	{
		clc
		ror tmp
		ror target
	}
}
	
.pseudocommand moveObject source;target
{
	lda target
	clc
	adc source
	sta target
	lda _16bit_nextArgument_objectStride(target)
	adc _16bit_nextArgument_objectStride(source)
	sta _16bit_nextArgument_objectStride(target)

}

.pseudocommand moveObjectWith8 source;target
{
	lda source
	and #128
	bne negative
	lda target
	clc
	adc source
	sta target
	lda _16bit_nextArgument_objectStride(target)
	adc #0
	sta _16bit_nextArgument_objectStride(target)
	jmp done
negative:
	lda target
	clc
	adc source
	sta target
	lda _16bit_nextArgument_objectStride(target)
	adc #$ff
	sta _16bit_nextArgument_objectStride(target)
	jmp done
done:	
}

.pseudocommand moveObject8 source;target
{
	lda target
	clc
	adc source
	sta target
}

.pseudocommand mov source;target
{
	lda source
	sta target
}

.pseudocommand swap source;target
{
	lda source
	sta $fb
	lda target
	sta source
	lda $fb
	sta target
}

.pseudocommand mov16 source;target
{
	lda source
	sta target
	lda _16bit_nextArgument(source)
	sta _16bit_nextArgument(target)
}

.pseudocommand compare16 arg1;arg2
{
	lda arg1
	sec
	sbc arg2
	lda _16bit_nextArgument(arg1)
	sbc _16bit_nextArgument(arg2)
	and #%10000000
}

.pseudocommand compare16_x arg1;val1lsb;val1msb
{
	lda arg1
	sec
	sbc val1lsb
	lda _16bit_nextArgument(arg1)
	sbc val1msb
	and #%10000000
}

.pseudocommand cmp16 val1word;val1lsb;val1msb
{
	lda val1word
	cmp val1lsb
	bne _pccmp16_01
	lda _16bit_nextArgument(val1word)
	cmp val1msb
_pccmp16_01:	
}

.pseudocommand compare8 arg1;arg2
{
	lda arg1
	sec
	sbc arg2
}

.pseudocommand add8 value;target
{
	lda target
	clc
	adc value
	sta target
}

.pseudocommand add16 value;target
{
	lda target
	clc
	adc value
	sta target
	lda _16bit_nextArgument(target)
	adc _16bit_nextArgument(value)
	sta _16bit_nextArgument(target)
}

.pseudocommand add16e source;value;target
{
	lda source
	clc
	adc value
	sta target
	lda _16bit_nextArgument(source)
	adc _16bit_nextArgument(value)
	sta _16bit_nextArgument(target)
}

.pseudocommand add16e2 source;value;target1;target2
{
	lda source
	clc
	adc value
	sta target1
	sta target2
	lda _16bit_nextArgument(source)
	adc _16bit_nextArgument(value)
	sta _16bit_nextArgument(target1)
	sta _16bit_nextArgument(target2)
}

.pseudocommand sub8 value;target
{
	lda target
	sec
	sbc value
	sta target
}

.pseudocommand sub16 value;target
{
	lda target
	sec
	sbc value
	sta target
	lda _16bit_nextArgument(target)
	sbc _16bit_nextArgument(value)
	sta _16bit_nextArgument(target)
}
