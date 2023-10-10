class_name DangleOnEdge extends Object

static var bridge_def = BridgeDefinition.new(
	[
		# 0
		[Vector3( 0,  0,  0),  false,    0],
		[Vector3( 5,  0,  0),  false,    0],
		[Vector3( 0,  0,  5),  false,    0],
		[Vector3( 5,  0,  5),  false,    0],

		[Vector3( 0,  2,  0),   true,    0],
		[Vector3( 5,  2,  0),   true,    0],
		[Vector3( 0,  2,  5),   true,    0],
		[Vector3( 5, -3,  5),  false,  1000],
	],
	[
		[0, 1], [1, 2], [2, 3], [3, 0],
		[0, 2], [1, 3],
		[0, 4], [1, 5], [2, 6], [3, 7],
	],
	25, 9, 100
)
