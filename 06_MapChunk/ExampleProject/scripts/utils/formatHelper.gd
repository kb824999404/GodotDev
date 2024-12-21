extends Object

class_name FormatHelper

static func str_to_array_float(str: String) -> Array:
	var items = str.substr(1,str.length()-1).split(",")
	var res: Array = []
	for item in items:
		res.append(float(item))
	return res
	
static func str_to_array_int(str: String) -> Array:
	var items = str.substr(1,str.length()-1).split(",")
	var res: Array = []
	for item in items:
		res.append(int(item))
	return res

static func array_to_vector(arr:Array):
	if arr.size() == 2:
		return Vector2(arr[0],arr[1])
	elif arr.size() == 3:
		return Vector3(arr[0],arr[1],arr[2])
	else:
		return arr
