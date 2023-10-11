class_name Playground extends Object

static var bridge_def = BridgeDefinition.new({
	"nodes": [
		# 0
		[Vector3( -10,  0, -1.5),  true,    0],
		[Vector3(  -5,  0, -1.5), false,    0],
		[Vector3(   0,  0, -1.5), false,    0],
		[Vector3(   5,  0, -1.5), false,    0],
		[Vector3(  10,  0, -1.5), false,    0],
		# 5
		[Vector3( -10,  0,  1.5),  true,    0],
		[Vector3(  -5,  0,  1.5), false,    0],
		[Vector3(   0,  0,  1.5), false,    0],
		[Vector3(   5,  0,  1.5), false,    0],
		[Vector3(  10,  0,  1.5), false,    0],
		# 10
		[Vector3(-7.5,  4,    0),  true,    0],
		[Vector3(-2.5,  4,    0), false,    0],
		[Vector3( 2.5,  4,    0), false,    0],
		[Vector3( 7.5,  4,    0), false,    0],
		# 14
		[Vector3(-0.75,  4,    0), false,    0],
		[Vector3(-0.25,  4,    0), false,    0],
		[Vector3( 0.25,  4,    0), false,    0],
		[Vector3( 0.75,  4,    0), false,    0],
		# 18
		[Vector3(-0.5, 15,    0),  true,    0],
		[Vector3(-0.5, 10,    0), false,   14],
		[Vector3(-0.5,  5,    0.0001), false, 2000],
		# 21
		[Vector3( 0.5, 15,    0),  true,    0],
		[Vector3( 0.5, 14,    0), false,    0],
		[Vector3( 0.5, 13,    0), false,    0],
		[Vector3( 0.5, 12,    0), false,    0],
		[Vector3( 0.5, 11,    0), false,    0],
		[Vector3( 0.5, 10,    0), false,    0],
		[Vector3( 0.5,  9,    0), false,    0],
		[Vector3( 0.5,  8,    0), false,    0],
		[Vector3( 0.5,  7,    0), false,    0],
		[Vector3( 0.5,  6,    0), false,    0],
		[Vector3( 0.5,  5,    0.0001), false, 2000],
	],
	"beams": [
		[0, 1], [0, 10], [10, 1],
		[1, 2], [1, 11], [11, 2],
		[2, 3], [2, 12], [12, 3],
		[3, 4], [3, 13], [13, 4],

		[5, 6], [5, 10], [10, 6],
		[6, 7], [6, 11], [11, 7],
		[7, 8], [7, 12], [12, 8],
		[8, 9], [8, 13], [13, 9],
		
		[10, 11], 
		[11, 14], [14, 15], [15, 16], [16, 17], [17, 12], 
		[12, 13],
		
		[0, 5], [1, 6], [2, 7], [3, 8], [4, 9],
		[0, 6], [1, 7], [2, 8], [3, 9],
		
		[18, 19], [19, 20],
		[21, 22], [22, 23], [23, 24], [24, 25], [25, 26], [26, 27], [27, 28], [28, 29], [29, 30], [30, 31],
	],
	"delete_index": 25, "add_mass_index": 9, "add_mass": 500
})
