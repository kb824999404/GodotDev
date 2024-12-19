extends Node3D

class_name Chunk

# 是否待清理
var should_remove: bool = false

var blocks=[]  # 方块列表

func _init(block_dict:Dictionary,center: Vector3,
	block_list:Array,plant_list:Array,
	camera:Node, plant_manager:Node):
	position = center
	for item in block_list:
		var block:Node3D = block_dict[item.type][item.index].instantiate()
		block.position = item.position
		block.scale = item.scale
		block.name = item.name
		add_child(block)
		blocks.append(block)
	for item in plant_list:
		var plant: PlantEntity = plant_manager.instantiate_plant(item.plant_name,item.position)
		if plant:
			var initial_rotation = plant.rotation
			plant.name = item.name
			plant.initial_rotation = initial_rotation
			plant.request_ready()
			plant.init(camera,plant_manager)
			if item.type == "tree":
				plant.MAX_HP = 3
			add_child(plant)
