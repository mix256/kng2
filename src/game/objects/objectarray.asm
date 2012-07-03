
_objectarray_type:				// and ACTIVE if != 0
	.fill NUMBER_OF_OBJECTS, 0

_objectarray_collisionType:
	.fill NUMBER_OF_OBJECTS, 0

_objectarray_x_coord:
	.fill NUMBER_OF_OBJECTS, 0

_objectarray_x_msb_coord:
	.fill NUMBER_OF_OBJECTS, 0

_objectarray_y_coord:
	.fill NUMBER_OF_OBJECTS, 0

_objectarray_width:
	.fill NUMBER_OF_OBJECTS, 0

_objectarray_height:
	.fill NUMBER_OF_OBJECTS, 0

_objectarray_color:
	.fill NUMBER_OF_OBJECTS, 0

_objectarray_hits:
	.fill NUMBER_OF_OBJECTS, 0

_objectarray_was_hit:
	.fill NUMBER_OF_OBJECTS, 0

_objectarray_user_properties:
	.fill NUMBER_OF_OBJECTS, 0
	.fill NUMBER_OF_OBJECTS, 0
	.fill NUMBER_OF_OBJECTS, 0
	.fill NUMBER_OF_OBJECTS, 0
	.fill NUMBER_OF_OBJECTS, 0
	.fill NUMBER_OF_OBJECTS, 0
	.fill NUMBER_OF_OBJECTS, 0
	.fill NUMBER_OF_OBJECTS, 0
	
	
objectarray_clear:
	ldx #0
	txa
objectarray_c01:	
	sta _objectarray_type, x
	inx
	cpx #NUMBER_OF_OBJECTS
	bne objectarray_c01	
	rts