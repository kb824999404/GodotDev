extends Node3D

class_name Chunk

var should_remove: bool = false

var blocks=[]  # 方块列表

func _init(block_dict:Dictionary,center: Vector3,
	block_list:Array):
	position = center
	print(block_dict)
	for item in block_list:
		var block:Node3D = block_dict[item.type][item.index].instantiate()
		block.position = item.position
		block.scale = item.scale
		block.name = item.name
		add_child(block)
		print(block)
		#blocks.append(block)
