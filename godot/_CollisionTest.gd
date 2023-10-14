class_name CollisionTest extends Object

static var bridge_def = BridgeDefinition.new({
	"nodes": [
		# 0
		[Vector3(    0,  0.3,    0),   true,   0],
		[Vector3(    0,  0,    5),   true,   0],
		#[Vector3(    0,  0.0025,    5),   true,   0],
		[Vector3(    5,  0,    0),   true,   0],
		[Vector3(    5,  0.3,    5),   true,   0],
		[Vector3( 0.75,  2,  2.5),  false,   0, true],
	],
	"beams": [
		[0, 1], [1, 2], [2, 3], [3, 0],
		[0, 2], [1, 3],
	],
	"roads": [
		[0, 2]
	]
})
