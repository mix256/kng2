
	.const OBJECT_NONE = 0
	.const OBJECT_ENEMYBULLET = 2
	.const OBJECT_TRANSPORTER = 4
	.const OBJECT_PHOENIX = 6
	.const OBJECT_EXPLOSION = 8
	.const OBJECT_CAGE_LOCK = 10
	.const OBJECT_EYE = 12

_world_object_pointer_list:
	.word 0
	.word _label_1
	.word _label_2
	.word _label_3
	.word _label_4
	.word _label_5
	.word _label_6

_label_1:
	.import source "src/game/objects/common/enemybullet.asm"
_label_2:
	.import source "src/game/objects/common/transporter.asm"
_label_3:
	.import source "src/game/objects/common/phoenix.asm"
_label_4:
	.import source "src/game/objects/common/explosion.asm"
_label_5:
	.import source "src/game/objects/enemies/lock.asm"
_label_6:
	.import source "src/game/objects/enemies/eye.asm"