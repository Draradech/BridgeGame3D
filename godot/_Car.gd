class_name Car extends Object

const  w = 2.0
const  l = 4.0
const ww = 1.5
const wl = 2.5
const wh = 0.3
const bh = 0.5 + wh
const rh = 0.8 + bh

const wood = 0
const steel = 1
const car_spring = 2

static var bridge_def = BridgeDefinition.new({
	"nodes": [
		# 0 - body
		[Vector3( w/2,  bh,  l/2), false,  100],
		[Vector3(-w/2,  bh,  l/2), false,  100],
		[Vector3( w/2,  bh,    0), false,  100],
		[Vector3(-w/2,  bh,    0), false,  100],
		[Vector3( w/2,  bh, -l/2), false,  100],
		[Vector3(-w/2,  bh, -l/2), false,  100],
		# 6 - roof
		[Vector3( ww/2, rh,  wl/2), false, 100],
		[Vector3(-ww/2, rh,  wl/2), false, 100],
		[Vector3( ww/2, rh, -wl/2), false, 100],
		[Vector3(-ww/2, rh, -wl/2), false, 100],
		# 10 - wheels
		[Vector3( ww/2, wh,  wl/2), false,  100, true],
		[Vector3(-ww/2, wh,  wl/2), false,  100, true],
		[Vector3( ww/2, wh, -wl/2), false,  100, true],
		[Vector3(-ww/2, wh, -wl/2), false,  100, true],
	],
	"beams": [
		# body
		[0, 1, steel], [1, 3, steel], [3, 2, steel], [2, 0, steel], [0, 3, steel], [1, 2, steel],
					   [3, 5, steel], [5, 4, steel], [4, 2, steel], [2, 5, steel], [3, 4, steel],
		# roof
		[6, 7, steel], [7, 9, steel], [9, 8, steel], [8, 6, steel], [6, 9, steel], [7, 8, steel],
		# body-roof
		[0, 6, steel], [0, 7, steel], [1, 6, steel],
		[1, 7, steel], [3, 7, steel], [3, 9, steel],
		[5, 9, steel], [5, 8, steel], [4, 9, steel],
		[4, 8, steel], [2, 8, steel], [2, 6, steel],
		# wheels
		[10, 1, steel], [10, 3, steel], [10, 6, car_spring], 
		[11, 0, steel], [11, 2, steel], [11, 7, car_spring], 
		[13, 2, steel], [13, 4, steel], [13, 9, car_spring], 
		[12, 3, steel], [12, 5, steel], [12, 8, car_spring], 
	],
})
