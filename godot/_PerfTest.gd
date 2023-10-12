class_name PerfTest extends Object

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
		
		[10, 11], [11, 12], [12, 13],
		
		[0, 5], [1, 6], [2, 7], [3, 8], [4, 9],
		[0, 6], [1, 7], [2, 8], [3, 9],
	],
	"roads": [ [27, 28], [28, 29], [29, 30], [30, 31]],
	"delete_index": 25, "add_mass_index": 9, "add_mass": 500
})
