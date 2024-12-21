extends Node3D
class_name MapGenerator

@export_group("Property")
# 是否启用
@export var enabled: bool = true
# 随机种子
@export var RANDOM_SEED:int = 123

@export_group("Chunk")
# 区块大小
@export var chunk_size: int = 3
# 区块可见半径
@export var chunk_visible_radius: int = 1
# 区块缓存半径
@export var chunk_cache_radius: int = 2
# 强制更新区块信息
@export var chunk_force_update: bool = false
# 区块更新频率
@export var chunk_update_time: float = 0.1

@export_group("Resource Path")
# 方块文件夹
@export_dir var blocks_folder_path = "res://prefabs/blocks"
# 方块信息json文件
@export_file var blocks_dict_path = "res://prefabs/blocks/blocks.json"
# 地图布局文件路径
@export_file var map_file_path = ""



# 方块对象字典：键为类型名，值为对象列表
var block_dict = {}
# 方块类型名
var block_types = {}
# 区块信息字典
var chunks_info = {}
# 区块实例字典
var chunks = {}
# 需加载的区块
var unready_chunks = {}
# 区块可见性
var chunks_visible = {}
# 地图大小
var map_size: Vector2i
# 方块大小
var block_size: int
# 地图的偏移位置
var map_offset:Vector3
# 区块数量
var chunk_count:Vector2i
# 当前区块坐标
var curr_chunk_coord:Vector2i = Vector2i.ZERO
# 加载区块的线程
var spawn_thread: Thread
# 清理区块的线程
var kill_thread: Thread
# 区块更新计时器
var chunk_update_timer: Timer


func _ready():
	spawn_thread = Thread.new()
	kill_thread = Thread.new()
	chunk_update_timer = Timer.new()
	chunk_update_timer.timeout.connect(on_update_chunk)
	chunk_update_timer.set_wait_time(chunk_update_time)
	add_child(chunk_update_timer)
	

func init():
	if enabled:
		seed(RANDOM_SEED)
		# 读取blocks字典
		var blocks_path_dict = load(blocks_dict_path).data
		for key in blocks_path_dict:
			var index = key
			block_dict[index] = []
			block_types[index] = blocks_path_dict[key]["type"]
			for block_path in blocks_path_dict[key]["blocks"]:
				var block_resource_path = blocks_folder_path + "/" + block_path + ".tscn"
				var block_resource := load(block_resource_path)
				block_dict[index].append(block_resource)	
		var load_map_thread = Thread.new()
		load_map_thread.start(generate_map_from_file_chunks.bind([map_file_path,load_map_thread]))
	

func generate_map_from_file_chunks(args):
	var file_path: String = args[0]
	var thread: Thread = args[1]
	# 1.预先划分区块，存放区块加载信息
	# 区块加载信息：区块中心位置，方块列表（包含方块类型和相对与区块中心的位置）
	
	# 2.动态判断哪些区块需要加载和删除
	# 坐标映射函数：玩家全局坐标映射到网格坐标，网格坐标映射到区块坐标
	# 游戏帧：将玩家移动信号和该类的移动判断函数绑定，判断玩家所处的区块坐标，如果区块坐标发生改变，则调用区块更新函数
	# 区块更新判断：标记区块状态：加载、缓存、清除
	# 区块更新执行：新加载、清理、加载和缓存切换
	# 加载和缓存切换：对所有方块设置可见不可见
	# 新加载：单独用一个线程，用区块加载信息构造区块
	# 清理：单独用一个线程，释放方块资源，从区块列表中删除区块
	
	######################## 读取地图布局，预先划分区块 ########################
	var data = load(file_path).data
	# 地图大小
	map_size = Vector2(data["map_size"][1],data["map_size"][0]) 
	# 方块大小
	block_size = data["block_size"]
	# 计算地图的偏移位置，使中心点处于世界原点
	map_offset = -Vector3(map_size.x*block_size/2,0,map_size.y*block_size/2.0)
	# 计算区块数量
	chunk_count = Vector2i(ceil(map_size/float(chunk_size)))
	print("Map Size:",map_size)
	print("Block Size:",block_size)
	print("Map Offset:",map_offset)
	print("Chunk Count:",chunk_count)
	
	# 地图数据
	var map_data = data["map"]
	
	# 区块信息文件路径
	var chunks_info_path = file_path.get_basename() + "_chunks.json"
	if not FileAccess.file_exists(chunks_info_path) or chunk_force_update:
		print("Preprocess Chunks...")
		# 预先划分区块，优先从缓存中读取
		for chunk_y in range(chunk_count.y):
			for chunk_x in range(chunk_count.x):
				# 存放区块加载信息：区块中心位置，方块列表（包含方块类型和相对与区块中心的位置）
				# 区块键
				var chunk_key = [chunk_y,chunk_x]
				# 区块中心位置
				var chunk_center_local = Vector3(chunk_x*chunk_size+chunk_size/2,0,chunk_y*chunk_size+chunk_size/2.0)* block_size
				var chunk_center_global = chunk_center_local + map_offset
				# 遍历区块内的每个方块，存放方块加载信息
				var chunk_blocks = []
				for y in range(chunk_y*chunk_size,(chunk_y+1)*chunk_size):
					for x in range(chunk_x*chunk_size,(chunk_x+1)*chunk_size):
						if y >= map_size.y or x >= map_size.x:
							continue
						if map_data[y][x] == '#':
							continue
						var block_type = map_data[y][x]
						if block_type in block_dict:
							var rand_index:int = randi() % block_dict[block_type].size()
							var block_name = "{0}_{1}_{2}".format([block_types[block_type],y,x])
							# 方块相对于区块中心的位置
							var block_position = Vector3(x, 0, y)* block_size - chunk_center_local
							# 方块缩放
							var block_scale = Vector3.ONE * block_size
							chunk_blocks.append({
								"type": block_type,
								"index": rand_index,
								"name": block_name,
								"position": block_position,
								"scale": block_scale,
							})
				chunks_info[chunk_key] = {
					"name": "chunk_"+"{0}_{1}".format(chunk_key),
					"center": chunk_center_global,
					"blocks": chunk_blocks,
				}	
		print("Preprocess Chunks Done.")
		# 保存区块信息到json
		FileHelper.save_to_json_file(chunks_info_path,chunks_info,"\t")
		print("Chunks Info Saved To ",chunks_info_path)
	else:
		print("Loading Chunks...")
		data = load(chunks_info_path).data
		for key_str: String in data:
			var info = data[key_str]
			var chunk_key = FormatHelper.str_to_array_int(key_str)
			var chunk_center = FormatHelper.array_to_vector(FormatHelper.str_to_array_float(info["center"]))
			var chunk_blocks = []
			for block in info["blocks"]:
				block["position"] = FormatHelper.array_to_vector(FormatHelper.str_to_array_float(block["position"]))
				block["scale"] = FormatHelper.array_to_vector(FormatHelper.str_to_array_float(block["scale"]))
				chunk_blocks.append(block)
			chunks_info[chunk_key] = {
				"name": "chunk_"+"{0}_{1}".format(chunk_key),
				"center": chunk_center,
				"blocks": chunk_blocks,
			}	
		print("Chunks Info Read From ",chunks_info_path)
	###################################################################
	
	call_deferred("on_map_loaded", thread)

# 加载完地图
func on_map_loaded(thread: Thread) -> void:
	on_player_move(Vector3.ZERO,true)
	chunk_update_timer.start()
	
	await get_tree().create_timer(1).timeout
	emit_signal("map_loaded")
	
	thread.wait_to_finish()


# 全局坐标映射到网格坐标
func pos_to_grid_coord(pos: Vector3):
	pos -= map_offset
	var grid_coord = floor(Vector2(pos.x/block_size,pos.z/block_size))
	return grid_coord
	
# 网格坐标映射到区块坐标
func grid_to_chunk_coord(grid_coord:Vector2):
	var chunk_coord = Vector2i( floor(grid_coord/ chunk_size))
	# 处理越界情况
	chunk_coord.x = clampi(chunk_coord.x,0,chunk_count.x-1)
	chunk_coord.y = clampi(chunk_coord.y,0,chunk_count.y-1)
	return chunk_coord

# 玩家移动
func on_player_move(pos:Vector3,force_update:bool=false):
	var chunk_coord = grid_to_chunk_coord(pos_to_grid_coord(pos))
	if curr_chunk_coord != chunk_coord or force_update:
		var curr_key = var_to_str([curr_chunk_coord.y,curr_chunk_coord.x])
		var new_key = var_to_str([chunk_coord.y,chunk_coord.x])
		print("Player Move: {0} -> {1}".format([curr_key,new_key]))
		on_chunk_preupdate(chunk_coord)
		curr_chunk_coord = chunk_coord

# 区块预更新
func on_chunk_preupdate(new_chunk_coord:Vector2i):
	# 处理已加载的区块
	for key in chunks.keys():
		var chunk_y = key[0]
		var chunk_x = key[1]
		var distance: int = max(abs(chunk_y-new_chunk_coord.y),abs(chunk_x-new_chunk_coord.x))
		# 需清理的区块
		if distance > chunk_cache_radius:
			var chunk: Chunk = chunks[key]
			chunk.should_remove = true
			chunks_visible[key] = 0
		# 不可见的区块
		elif distance > chunk_visible_radius:
			chunks_visible[key] = 0
		# 可见的区块
		else:
			chunks_visible[key] = 1
	# 处理未加载的区块
	for distance in range(chunk_cache_radius+1):
		var coords = []
		if distance == 0:
			coords.append([new_chunk_coord.y,new_chunk_coord.x])
		else:
			for dy in range(-distance,distance+1):
				var chunk_y = new_chunk_coord.y + dy
				var chunk_x = new_chunk_coord.x + distance
				coords.append([chunk_y,chunk_x])
				chunk_x = new_chunk_coord.x - distance
				coords.append([chunk_y,chunk_x])
			for dx in range(-distance+1,distance):
				var chunk_x = new_chunk_coord.x + dx
				var chunk_y = new_chunk_coord.y + distance
				coords.append([chunk_y,chunk_x])
				chunk_y = new_chunk_coord.y - distance
				coords.append([chunk_y,chunk_x])
		for coord in coords:
			var chunk_y = coord[0]
			var chunk_x = coord[1]
			# 超出地图范围
			if chunk_y <0 or chunk_y >= chunk_count.y or chunk_x <0 or chunk_x >= chunk_count.x:
				continue
			# 加载区块
			var key = [chunk_y,chunk_x]
			# 区块未加载
			if not chunks.has(key):
				# 加入待加载列表
				if not unready_chunks.has(key):
					unready_chunks[key] = 1
			# 缓存区的区块不可见
			if distance > chunk_visible_radius:
				chunks_visible[key] = 0
			else:
				chunks_visible[key] = 1

# 更新区块
func on_update_chunk():
	# 加载区块
	for key in unready_chunks:
		if not spawn_thread.is_started():
			spawn_thread.start(load_chunk.bind([spawn_thread, key]))
	# 处理区块可见性和清理区块
	for key in chunks:
		var chunk: Chunk = chunks[key]
		if chunks_visible[key]:
			chunk.visible = true
		else:
			chunk.visible = false
		if chunk.should_remove:
			if not kill_thread.is_started():
				kill_thread.start(free_chunk.bind([chunk, key, kill_thread]))

# 清理区块
func free_chunk(args) -> void:
	var chunk = args[0]
	var key = args[1]
	var thread = args[2]

	chunks.erase(key)
	chunk.queue_free()
	print("Free Chunk: ",key)
	call_deferred("free_chunk_done", thread)

# 清理完区块
func free_chunk_done(thread: Thread) -> void:
	thread.wait_to_finish()

# 加载区块
func load_chunk(args: Array) -> void:
	var thread = args[0]
	var key = args[1]
	
	var info = chunks_info[key]
	var chunk = Chunk.new(block_dict,info.center,info.blocks)
	chunk.name = info.name
	chunks[key] = chunk
	if not chunks_visible.has(key) or not chunks_visible[key]:
		chunk.visible = false
	unready_chunks.erase(key)
		
	print("Load Chunk: ",key)
	call_deferred("load_chunk_done", key, chunk, thread)

# 加载完区块
func load_chunk_done(key, chunk: Chunk, thread: Thread) -> void:
	add_child(chunk)
	thread.wait_to_finish()
