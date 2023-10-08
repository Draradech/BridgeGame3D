class_name AngeTruss2
extends Object

static var bridge_def = BridgeDefinition.new(
	[
		# 0
		[Vector3(  -6,  0,  0),  true,    0],
		[Vector3(  -4,  0,  0), false,    0],
		[Vector3(  -2,  0,  0), false,    0],
		[Vector3(   0,  0,  0), false,    0],
		[Vector3(   2,  0,  0), false,    0],
		[Vector3(   4,  0,  0), false,    0],
		[Vector3(   6,  0,  0),  true,    0],
		# 7
		[Vector3(  -4,  2,  0), false,    0],
		[Vector3(  -2,  2,  0), false,    0],
		[Vector3(   0,  2,  0), false,    0],
		[Vector3(   2,  2,  0), false,    0],
		[Vector3(   4,  2,  0), false,    0],
		# 12
		[Vector3(   0, -2,  0), false, 3000],
	],
	[
		[0, 1], [1, 2], [4, 5], [5, 6],
		[7, 8], [8, 9], [9, 10], [10, 11],
		[7, 1], [8, 2], [9, 3], [10, 4], [11, 5],
		[0, 7], [1, 8], [2, 9], [4, 9], [5, 10], [6, 11],
		[3, 12],
	],
	-1, -1, 0, true
)
