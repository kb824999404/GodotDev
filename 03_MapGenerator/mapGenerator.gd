extends Node

var block_dict = {}
var block_types = {}
@export_dir var blocks_folder_path = "res://prefabs/blocks"
@export_file var blocks_dict_path = "res://prefabs/blocks/blocks.json"
@export_file var map_file_path = ""
@export_file var map_saved_path = "res://scenes/maps/map01.tscn"
	
@export var block_size = 4


const RANDOM_SEED = 123

func _ready():
	seed(RANDOM_SEED)
	# 读取blocks字典
	var blocks_path_dict = load(blocks_dict_path).data
	for key in blocks_path_dict:
		var index = int(key)
		block_dict[index] = []
		block_types[index] = blocks_path_dict[key]["type"]
		for block_path in blocks_path_dict[key]["blocks"]:
			var block_resource_path = blocks_folder_path + "/" + block_path + ".tscn"
			var block_resource := load(block_resource_path)
			block_dict[index].append(block_resource)
	generate_map_from_file(map_file_path)

func generate_map_from_file(file_path):
	# 创建一个文件读取对象
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file.is_open():
		print("无法打开数据文件: ", file_path)
		return

	var map_data = []
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() > 0 and line[0].length() > 0:
			map_data.append(line)
	
	file.close()
		
	var map_size_x = map_data[0].size()
	var map_size_y = map_data.size()

	# 计算地图的起始位置，使中心点处于世界原点
	var start_x = -map_size_x / 2
	var start_y = -map_size_y / 2

	# 遍历地图数据并生成地图
	for y in range(map_size_y):
		for x in range(map_size_x):
			if map_data[y][x] == '#':
				continue
			var block_type = int(map_data[y][x])
			if block_type in block_dict:
				var rand_index:int = randi() % block_dict[block_type].size()
				var block_instance = block_dict[block_type][rand_index].instantiate()
				block_instance.transform.origin = Vector3((start_x + x) * block_size, 0, (start_y + y) * block_size)
				block_instance.set_name("{0}_{1}_{2}".format([block_types[block_type],y,x]))
				add_child(block_instance)
				block_instance.set_owner(self)



func save_map_as_file():
	var scene = PackedScene.new()
	var result = scene.pack(self)
	if result == OK:
		var error = ResourceSaver.save(scene, map_saved_path)
		if error != OK:
			push_error("将场景保存到磁盘时出错。")
		else:
			print("保存场景成功：{0}".format([map_saved_path]))
