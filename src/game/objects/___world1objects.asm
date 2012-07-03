
	.const	OBJECT_NONE				= 0
	.const	OBJECT_STONEFACE		= 2
	.const	OBJECT_EXPLOSION		= 4
	.const	OBJECT_PILLAR			= 6
	.const	OBJECT_TRANSPORTER		= 8
	.const	OBJECT_LIZ				= 10
	.const	OBJECT_ENEMYBULLET		= 12
	.const	OBJECT_BIGFACE			= 14
	.const	OBJECT_LARGEPILLAR		= 16
	.const	OBJECT_PHOENIX			= 18
	.const	OBJECT_DROP				= 20

_world1_object_pointer_list:
	.word 0						// inactive object
	.word stoneface_routines	// enemy 1...etc
	.word explosion_routines
	.word pillar_routines
	.word transporter_routines
	.word liz_routines
	.word enemybullet_routines
	.word bigface_routines
	.word largepillar_routines
	.word phoenix_routines
	.word drop_routines

.import source "src/game/objects/enemies/stoneface.asm"
.import source "src/game/objects/common/explosion.asm"
.import source "src/game/objects/common/phoenix.asm"
.import source "src/game/objects/enemies/pillar.asm"
.import source "src/game/objects/common/transporter.asm"
.import source "src/game/objects/enemies/liz.asm"
.import source "src/game/objects/common/enemybullet.asm"
.import source "src/game/objects/enemies/bigface.asm"
.import source "src/game/objects/enemies/largepillar.asm"
.import source "src/game/objects/enemies/drop.asm"

