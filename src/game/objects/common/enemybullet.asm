
.const ENEMYBULLET_START_FRAME	=	FRAME_MAIN_START + 28
.const ENEMYBULLET_END_FRAME	=	FRAME_MAIN_START + 31

enemybullet_routines:
	jmp enemybullet_create
	jmp enemybullet_update
	jmp enemybullet_dead
	jmp enemybullet_draw

enemybullet_create:

	:setUnShiftedObjectPosition _objectarray_x_coord, x;_objectarray_user_properties + [NUMBER_OF_OBJECTS * 2], x
	:setUnShiftedObjectPosition8 _objectarray_y_coord, x;_objectarray_user_properties + [NUMBER_OF_OBJECTS * 4], x

	lda #COLLISION_WITH_MAIN
	sta _objectarray_collisionType, x

	lda #1
	sta _objectarray_hits, x

	lda #8
	sta _objectarray_width, x
	lda #6
	sta _objectarray_height, x

	lda #ANIMATION_TYPE_LOOP
	sta _animation_type, x
	lda #ENEMYBULLET_START_FRAME
	sta _animation_start_frame, x
	lda #ENEMYBULLET_END_FRAME
	sta _animation_end_frame, x
	lda #5
	sta _animation_speed, x
	jsr animation_setAnimation
	
	rts

enemybullet_tmp:
	.byte 0

enemybullet_dead2:
	jmp enemybullet_dead
enemybullet_update:
	lda _objectarray_was_hit, x
//	bne enemybullet_dead2

	// Check clipping
	jsr objectroutines_clipObject

	// Move
	:setShiftedObjectPosition  _objectarray_user_properties + [NUMBER_OF_OBJECTS * 2], x;_objectarray_x_coord, x
	:setShiftedObjectPosition8  _objectarray_user_properties + [NUMBER_OF_OBJECTS * 4], x;_objectarray_y_coord, x;enemybullet_tmp
	
	:moveObjectWith8 _objectarray_user_properties + [NUMBER_OF_OBJECTS * 0], x;_objectarray_user_properties + [NUMBER_OF_OBJECTS * 2], x
	:moveObjectWith8 _objectarray_user_properties + [NUMBER_OF_OBJECTS * 1], x;_objectarray_user_properties + [NUMBER_OF_OBJECTS * 4], x
	
	// Animate
	jsr animation_updateFrame

	// Draw
	jsr enemybullet_draw
	rts

enemybullet_draw:
	jsr objectroutines_drawObject
	rts

enemybullet_dead:
	lda #OBJECT_NONE
	sta _objectarray_type, x
	rts

